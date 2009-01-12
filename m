Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:50880 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752282AbZALEDC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Jan 2009 23:03:02 -0500
Message-ID: <496ABF0E.2010502@melbourne.sgi.com>
Date: Mon, 12 Jan 2009 14:54:54 +1100
From: Greg Banks <gnb@melbourne.sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS list <linux-nfs@vger.kernel.org>, Neil Brown <neilb@suse.de>
Subject: RFC: sunrpc upcall test infrastructure
Content-Type: multipart/mixed;
 boundary="------------070806030004090902060808"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------070806030004090902060808
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

G'day,

This patch and userspace code are not to be applied, they're just being
posted in case anyone wants to continue this work (Hi Neil!).  They
provide a kernel module and a small userspace program which can be used
as infrastructure for testing various aspects of the sunrpc cache upcall
mechanism.  The kernel module is for SLES10 and thus has several archaic
features like DefineSimpleCacheLookup(), but could be easily ported to
modern code.  Missing are a shell or Python driver to run automated test
cases, and a better way of testing for failure than drawling dmesg. 
However in the absence of those this code has proven useful for a small
amount of manual testing.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.


--------------070806030004090902060808
Content-Type: text/plain;
 name="gnb-pv988959-add-cache-detail-test"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="gnb-pv988959-add-cache-detail-test"

Index: src/debug/Makefile
===================================================================
--- src.orig/debug/Makefile
+++ src/debug/Makefile
@@ -7,3 +7,5 @@ obj-m += dprintk.o
 # Uncomment this to build a module for testing dprintk.ko
 # obj-m += test-dprintk.o
 
+obj-m += sgi-cache-test.o
+
Index: src/debug/sgi-cache-test.c
===================================================================
--- /dev/null
+++ src/debug/sgi-cache-test.c
@@ -0,0 +1,391 @@
+/*
+ * Test driver for stress-testing the sunrpc cache
+ * upcall mechanism.  Derived from svcauth_unix.c
+ * Create a simple cache which stores MD5 sums of
+ * words and a pseudo-file which can be used to
+ * trigger a lookup from userspace.
+ *
+ * Portions Copyright (c) 2008 Silicon Graphics, Inc.
+ *	    All Rights Reserved.
+ * By Greg Banks <gnb@melbourne.sgi.com>
+ */
+#include <linux/types.h>
+#include <linux/sched.h>
+#include <linux/module.h>
+#include <linux/sunrpc/types.h>
+#include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/svcauth.h>
+#include <linux/err.h>
+#include <linux/seq_file.h>
+#include <linux/jhash.h>
+#include <linux/string.h>
+#include <linux/ctype.h>
+#include <net/sock.h>
+
+#define RPCDBG_FACILITY	RPCDBG_CACHE
+
+#define WORD_LENGTH	512
+#define DIGEST_LENGTH	(2*16)	/* stored in ASCII 'cos I'm lazy */
+struct sgi_test
+{
+	struct cache_head h;
+	char *word;
+	char digest[DIGEST_LENGTH+1];
+};
+
+struct cache_sleeper
+{
+	struct cache_req req;
+	struct cache_deferred_req dreq;
+	wait_queue_head_t waitq;
+	atomic_t count;
+};
+
+#define	SGI_TEST_HASHBITS	8
+#define	SGI_TEST_HASHMAX	(1<<SGI_TEST_HASHBITS)
+#define	SGI_TEST_HASHMASK	(SGI_TEST_HASHMAX-1)
+
+static struct cache_head	*sgi_test_table[SGI_TEST_HASHMAX];
+
+static void sgi_test_put(struct cache_head *item, struct cache_detail *cd)
+{
+	struct sgi_test *st = container_of(item, struct sgi_test,h);
+	dprintk("sgi_test_put(item=%p) refcnt=%d\n",
+		item, atomic_read(&item->refcnt));
+	if (cache_put(item, cd)) {
+		kfree(st->word);
+		st->word = NULL;
+		kfree(st);
+	}
+}
+
+static int sgi_test_hash(struct sgi_test *item)
+{
+	dprintk("sgi_test_hash(item=%p) word=\"%s\"\n",
+		item, item->word);
+	return jhash(item->word, strlen(item->word),
+		     0xdeadbeef) & SGI_TEST_HASHMASK;
+}
+
+static int sgi_test_match(struct sgi_test *item, struct sgi_test *tmp)
+{
+	return (strcmp(tmp->word, item->word) == 0);
+}
+
+static void sgi_test_init(struct sgi_test *new, struct sgi_test *item)
+{
+	new->word = kstrdup(item->word, GFP_KERNEL);
+	memcpy(new->digest, item->digest, sizeof(new->digest));
+	dprintk("sgi_test_init(new=%p, item=%p) item->word=\"%s\"\n",
+		new, item, item->word);
+}
+
+static void sgi_test_update(struct sgi_test *new, struct sgi_test *item)
+{
+	kfree(new->word);
+	new->word = kstrdup(item->word, GFP_KERNEL);
+	memcpy(new->digest, item->digest, sizeof(new->digest));
+	dprintk("sgi_test_update(new=%p, item=%p) item->word=\"%s\"\n",
+		new, item, item->word);
+}
+
+static void sgi_test_request(struct cache_detail *cd,
+			     struct cache_head *h,
+			     char **bpp, int *blen)
+{
+	struct sgi_test *st = container_of(h, struct sgi_test, h);
+
+	dprintk("sgi_test_request(st=%p) word=\"%s\"\n",
+		st, st->word);
+
+	qword_add(bpp, blen, st->word);
+	(*bpp)[-1] = '\n';
+}
+
+static struct sgi_test *sgi_test_lookup(struct sgi_test *, int);
+
+static int sgi_test_parse(struct cache_detail *cd,
+			  char *mesg, int mlen)
+{
+	/* word expiry [digest] */
+	int len;
+	struct sgi_test st, *stp;
+	time_t expiry;
+	int err = -EINVAL;
+
+	dprintk("sgi_test_parse: starts\n");
+	memset(&st, 0, sizeof(st));
+
+	if (mesg[mlen-1] != '\n')
+		goto out;
+	mesg[mlen-1] = 0;
+
+	err = -ENOMEM;
+	st.word = kmalloc(WORD_LENGTH, GFP_KERNEL);
+	if (!st.word)
+		goto out;
+
+	err = -EINVAL;
+
+	/* class */
+	len = qword_get(&mesg, st.word, WORD_LENGTH);
+	if (len <= 0)
+		goto out;
+
+	expiry = get_expiry(&mesg);
+	if (expiry == 0)
+		goto out;
+
+	/* digest, or empty for NEGATIVE */
+	len = qword_get(&mesg, st.digest, sizeof(st.digest)-1);
+	if (len < 0 || len >= DIGEST_LENGTH)
+		goto out;
+	st.digest[len] = '\0';
+	if (!len)
+		set_bit(CACHE_NEGATIVE, &st.h.flags);
+
+	st.h.expiry_time = expiry;
+
+	err = -ENOMEM;
+	stp = sgi_test_lookup(&st, 1);
+	if (!stp)
+		goto out;
+
+	sgi_test_put(&stp->h, cd);
+	cache_flush();
+	err = 0;
+out:
+	kfree(st.word);
+	return err;
+}
+
+static int sgi_test_show(struct seq_file *m,
+		         struct cache_detail *cd,
+		         struct cache_head *h)
+{
+	struct sgi_test *st;
+
+	if (h == NULL) {
+		seq_puts(m, "#word digest flags\n");
+		return 0;
+	}
+	st = container_of(h, struct sgi_test, h);
+
+	seq_printf(m, "%s %s %s,%s,%s\n",
+		   st->word,
+		   st->digest,
+		   (test_bit(CACHE_VALID, &h->flags) ? "valid" : "!valid"),
+		   (test_bit(CACHE_NEGATIVE, &h->flags) ? "negative" : "!negative"),
+		   (test_bit(CACHE_PENDING, &h->flags) ? "pending" : "!pending"));
+	return 0;
+}
+
+
+struct cache_detail sgi_test_cache = {
+	.owner		= THIS_MODULE,
+	.hash_size	= SGI_TEST_HASHMAX,
+	.hash_table	= sgi_test_table,
+	.name		= "sgi.test",
+	.cache_put	= sgi_test_put,
+	.cache_request	= sgi_test_request,
+	.cache_parse	= sgi_test_parse,
+	.cache_show	= sgi_test_show,
+};
+
+static DefineSimpleCacheLookup(sgi_test, 0)
+
+static inline void
+sleeper_put(struct cache_sleeper *sl)
+{
+	if (atomic_dec_and_test(&sl->count)) {
+		dprintk("sleeper_put: pid %d freeing %p\n", current->pid, sl);
+		kfree(sl);
+	}
+}
+
+static inline void
+sleeper_get(struct cache_sleeper *sl)
+{
+	atomic_inc(&sl->count);
+}
+
+
+static void
+sleeper_revisit(struct cache_deferred_req *dreq, int toomany)
+{
+	struct cache_sleeper *sl = container_of(dreq, struct cache_sleeper, dreq);
+
+	dprintk("sleeper_revisit: pid %d sl=%p\n", current->pid, sl);
+	wake_up(&sl->waitq);
+	sleeper_put(sl);
+}
+
+static struct cache_deferred_req *
+sleeper_defer(struct cache_req *req)
+{
+	struct cache_sleeper *sl = container_of(req, struct cache_sleeper, req);
+	dprintk("sleeper_defer: pid %d sl=%p\n", current->pid, sl);
+
+	sl->dreq.revisit = sleeper_revisit;
+	sleeper_get(sl);
+	return &sl->dreq;
+}
+
+static struct cache_sleeper *
+sleeper_new(void)
+{
+	struct cache_sleeper *sl;
+
+	sl = kzalloc(sizeof(*sl), GFP_KERNEL);
+	if (!sl)
+		return NULL;
+
+	atomic_set(&sl->count, 1);
+	init_waitqueue_head(&sl->waitq);
+	sl->req.defer = sleeper_defer;
+
+	dprintk("sleeper_new: pid %d sl=%p\n", current->pid, sl);
+
+	return sl;
+}
+
+static struct sgi_test *
+sgi_test_sleeping_lookup(const struct sgi_test *key)
+{
+	struct cache_sleeper *sl;
+	struct sgi_test *stp;
+	int ret;
+#define NUMTRIES 3
+	int try = 0;
+
+	sl = sleeper_new();
+	if (!sl) {
+		printk(KERN_INFO "pid %d ran out of memory cretaing sleeper\n",
+			current->pid);
+		return NULL;
+	}
+
+retry:
+	printk(KERN_INFO "pid %d looking up word \"%s\", try %d\n",
+		current->pid, key->word, try);
+
+	stp = sgi_test_lookup(key, 1);
+	dprintk("sgi_test_sleeping_lookup: key=%p stp=%p\n", key, stp);
+	if (stp == NULL) {
+		printk(KERN_INFO "pid %d no response (2)\n",
+			current->pid);
+		return NULL;
+	}
+
+	ret = cache_check(&sgi_test_cache, &stp->h, &sl->req);
+	switch (ret)
+	{
+	case -EAGAIN:
+		wait_event_interruptible_timeout(sl->waitq,
+			test_bit(CACHE_VALID, &stp->h.flags), 1 * HZ);
+		if (++try < NUMTRIES)
+			goto retry;
+		break;
+	case -ENOENT:
+		printk(KERN_INFO "pid %d no response (1)\n",
+			current->pid);
+		break;
+	case 0:
+		printk(KERN_INFO "pid %d valid response \"%s\"\n",
+			current->pid, stp->digest);
+		break;
+	default:
+		printk(KERN_INFO "pid %d got error %d from cache_check\n",
+			current->pid, (int)ret);
+		break;
+	}
+	sleeper_put(sl);
+	return (ret ? NULL : stp);
+}
+
+static ssize_t
+check_write(struct file *file, const char __user *ubuf,
+	    size_t ulen, loff_t *offp)
+{
+	ssize_t ret;
+	int i;
+	struct sgi_test st, *stp;
+
+	memset(&st, 0, sizeof(st));
+
+	ret = -ENOMEM;
+	st.word = kmalloc(WORD_LENGTH, GFP_KERNEL);
+	if (st.word == NULL)
+		goto out;
+
+	ret = -EINVAL;
+	if (ulen >= WORD_LENGTH)
+		goto out;
+
+	ret = -EFAULT;
+	if (copy_from_user(st.word, ubuf, ulen))
+		goto out;
+	/* ensure the line is nul-terminated */
+	st.word[ulen] = '\0';
+	/* trim any trailing whitespace, including newlines */
+	for (i = ulen-1 ; i >= 0 && isspace(st.word[i]) ; --i)
+		st.word[i] = '\0';
+
+	stp = sgi_test_sleeping_lookup(&st);
+
+	if (stp)
+		sgi_test_put(&stp->h, &sgi_test_cache);
+
+	*offp += ulen;
+	ret = ulen;
+out:
+	kfree(st.word);
+	return ret;
+}
+
+static struct file_operations check_fops =
+{
+	.owner = THIS_MODULE,
+	.write = check_write
+};
+
+static struct proc_dir_entry *check_entry;
+
+static int __init init_sgi_test(void)
+{
+	struct proc_dir_entry *p;
+
+	printk(KERN_INFO "SGI cache_detail test module\n");
+	printk(KERN_INFO "    Copyright (c) 2008 Silicon Graphics.\n");
+	printk(KERN_INFO "    Greg Banks <gnb@melbourne.sgi.com>\n");
+
+	cache_register(&sgi_test_cache);
+	if (sgi_test_cache.proc_ent) {
+ 		p = create_proc_entry("check", S_IFREG|S_IWUSR,
+ 				      sgi_test_cache.proc_ent);
+ 		if (p) {
+ 			p->proc_fops = &check_fops;
+ 			p->owner = THIS_MODULE;
+			check_entry = p;
+ 		}
+	}
+
+	return 0;
+}
+
+static void __exit exit_sgi_test(void)
+{
+	cache_purge(&sgi_test_cache);
+	if (check_entry)
+		remove_proc_entry("check", sgi_test_cache.proc_ent);
+	if (cache_unregister(&sgi_test_cache))
+		printk(KERN_ERR "sgi-test: failed to unregister sgi_test cache\n");
+}
+
+MODULE_AUTHOR("Greg Banks <gnb@melbourne.sgi.com>");
+MODULE_LICENSE("GPL");
+module_init(init_sgi_test);
+module_exit(exit_sgi_test);
+
+/* vim:set sw=8 sts=8 ai: */

--------------070806030004090902060808
Content-Type: text/plain;
 name="Makefile"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="Makefile"

#
# Userspace program to read the "sgi.test" sunrpc channel
# and respond with the MD5 sum of the word passed in the
# upcall.  Used to provide userspace behaviour to test
# the sunrpc cache upcall mechanism.
#
# Copyright (c) 2008 Silicon Graphics, Inc.
#	All Rights Reserved.
# By Greg Banks <gnb@melbourne.sgi.com>
#

default:    reader

OPENSSL_CFLAGS=
OPENSSL_LIBS=	-lcrypto

CFLAGS=	-Wall -g $(OPENSSL_CFLAGS)
LDLIBS=	$(OPENSSL_LIBS)

reader: reader.c
	$(LINK.c) -o $@ reader.c $(LDLIBS)

--------------070806030004090902060808
Content-Type: text/x-csrc;
 name="reader.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="reader.c"

/*
 * Userspace program to read the "sgi.test" sunrpc channel
 * and respond with the MD5 sum of the word passed in the
 * upcall.  Used to provide userspace behaviour to test
 * the sunrpc cache upcall mechanism.
 *
 * Copyright (c) 2008 Silicon Graphics, Inc.
 *	All Rights Reserved.
 * By Greg Banks <gnb@melbourne.sgi.com>
 */
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>
#include <ctype.h>
#include <errno.h>
#include <string.h>
#include <openssl/md5.h>
#include <sys/poll.h>
#include <sys/signal.h>
#include <sys/wait.h>
#include <time.h>
#include <sched.h>

#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif

#define min(x,y)	((x)<=(y)?(x):(y))
int blocksize = 128;
int timeout_ms = -1;
int entry_life_s = 10;
int delay_ms = 0;
int nthreads = 1;
char *argv0;

const struct option opts[] =
{
    {"blocksize",TRUE,NULL,'b'},
    {"timeout",TRUE,NULL,'T'},
    {"entry-life",TRUE,NULL,'l'},
    {"delay",TRUE,NULL,'d'},
    {"threads",TRUE,NULL,'t'},
    {NULL,0,NULL,0}
};

static void usage(int ec)
{
    fprintf(stderr, "Usage: %s [options]\n", argv0);
    fputs(
	"    [options] are:\n"
	"--blocksize=BYTES\n"
	"-b BYTES                Specify the size in bytes of the read()s performed\n"
	"                        on the upcall file descriptor; default 128.\n"
	"--timeout=MILLISEC\n"
	"-T MILLISEC             Specify the timeout when waiting for activity\n"
	"                        on the upcall file descriptor, or -1 to wait\n"
	"                        forever.  Default -1.\n"
	"--entry-life=SEC\n"
	"-l SEC                  Specify how long into the future each upcall\n"
	"                        reply will be scheduled to live.  Default 10.\n"
	"--delay=MILLISEC\n"
	"-d MILLISEC             Specify a delay between reading the upcall\n"
	"                        and replying, or 0 for no delay.  Default 0.\n"
	"--threads=INT\n"
	"-t INT                  Specify the number of reader threads to spawn,\n"
	"                        default 1.\n"
	,stderr);
    fflush(stderr);
    exit(ec);
}

static void
parse_args(int argc, char **argv)
{
    int c;
    int idx;

    argv0 = strrchr(argv[0], '/');
    if (argv0 == NULL)
	argv0 = argv[0];
    else
	argv0++;

    while ((c = getopt_long(argc, argv, "b:T:l:d:t:", opts, &idx)) >= 0)
    {
	switch (c)
	{
	case 'b':
	    blocksize = atoi(optarg);
	    if (blocksize < 1 || blocksize > 1024*1024)
	    {
		fprintf(stderr, "%s: bad value for option --blocksize \"%s\"\n",
		        argv0, optarg);
		usage(1);
	    }
	    break;
	case 't':
	    nthreads = atoi(optarg);
	    if (nthreads < 1 || nthreads > 128)
	    {
		fprintf(stderr, "%s: bad value for option --threads \"%s\"\n",
		        argv0, optarg);
		usage(1);
	    }
	    break;
	case 'T':
	    timeout_ms = atoi(optarg);
	    break;
	case 'l':
	    entry_life_s = atoi(optarg);
	    break;
	case 'd':
	    delay_ms = atoi(optarg);
	    break;
	default:
	    usage(1);
	}
    }
}

static int
read_message(FILE *fp, char *buf, int maxlen)
{
    int len = 0;
    int n;
    int bs;
    struct pollfd pfd;
    int nreads = 0;

    pfd.fd = fileno(fp);
    pfd.events = POLLIN;
    pfd.revents = 0;
    n = poll(&pfd, 1, timeout_ms);
    if (n < 0)
	return -1;
    if (n == 0)
    {
	errno = ETIMEDOUT;
	return -1;
    }
    if (n > 1)
    {
	errno = EINVAL;
	return -1;
    }

    while (len < maxlen)
    {
	bs = min(blocksize, maxlen-len);
	n = read(fileno(fp), buf+len, bs);
	nreads++;
	if (n > bs)
	{
	    fprintf(stderr, "%s: WTF? asked for %d bytes got %d\n",
		    argv0, bs, n);
	    errno = EINVAL;
	    return -1;
	}
	if (n < 0)
	    return -1;
	if (n == 0)
	    break;	/* no more data, must be end of message */
	len += n;
	if (buf[len-1] == '\n')
	    break;	/* end of message indicator */
    }
    if (nreads > 1)
	fprintf(stderr, "%s: read %d bytes in %d calls\n", argv0, len, nreads);
    return len;
}

static void
hex_to_ascii(const unsigned char *d, int len, char *out)
{
    while (len > 1)
    {
	static const char hexdigits[] = "0123456789ABCDEF";
	*out++ = hexdigits[(*d) >> 4];
	*out++ = hexdigits[(*d) & 0xf];
	d++;
	len--;
    }
    *out = '\0';
}

static int
handle_message(FILE *fp, char *buf, int len)
{
    time_t expiry;
    char *p;
    unsigned char digest[MD5_DIGEST_LENGTH];
    char digest_ascii[MD5_DIGEST_LENGTH*2+1];

    /* ensure the message is nul-terminated */
    buf[len] = '\0';
    /* remove any trailing whitespace */
    while (len > 0 && isspace(buf[len-1]))
	buf[--len] = '\0';
    /* check for any stray newlines */
    if ((p = strchr(buf, '\n')))
    {
	fprintf(stderr, "%s: newline in message, ignoring %d bytes\n",
		argv0, (int)((buf+len) - p));
	*p = '\0';
    }

    if (len == 0)
    {
	fprintf(stderr, "%s: zero length message, ignoring\n", argv0);
	return 0;
    }

    MD5((unsigned char *)buf, len, digest);
    hex_to_ascii(digest, sizeof(digest), digest_ascii);

    time(&expiry);
    expiry += entry_life_s;

    fprintf(stderr, "%s: got message: \"%s\" -> digest %s expires %ld\n",
	    argv0, buf, digest_ascii, (long)expiry);

    if (delay_ms)
    {
	fprintf(stderr, "%s: sleeping %d ms\n", argv0, delay_ms);
	poll(NULL, 0, delay_ms);
    }

    fprintf(fp, "%s %ld %s\n",
	    buf, (long)expiry, digest_ascii);
    fflush(fp);

    return 0;
}

static int
bind_to_cpu(int cpu)
{
    cpu_set_t set;

    CPU_ZERO(&set);
    CPU_SET(cpu, &set);
    return sched_setaffinity(0, CPU_SETSIZE, &set);
}

static pid_t *children;
int nchildren = 0;

static void
kill_children(void)
{
    int i;

    for (i=0 ; i<nchildren ; i++)
    {
	if (children[i] > 0)
	    kill(children[i], SIGKILL);
    }
}

static void
wait_for_children(void)
{
    int i;
    int status;
    pid_t pid;
    int remaining = nchildren;

    while (remaining > 0)
    {
	pid = waitpid(0, &status, 0);

	if (pid < 0)
	{
	    if (errno != ESRCH)
		perror("waitpid");
	    break;
	}


	for (i=0 ; i<nchildren ; i++)
	{
	    if (children[i] < 0)
		continue;
	    if (pid != children[i])
		continue;

	    children[i] = -1;
	    remaining--;

	    if (WIFEXITED(status))
	    {
		fprintf(stderr, "%s: child %d pid %d exited with status %d\n",
			argv0, i, (int)pid, WEXITSTATUS(status));
	    }
	    else if (WIFSIGNALED(status))
	    {
		fprintf(stderr, "%s: child %d pid %d killed by signal %d(%s)%s\n",
			argv0, i, (int)pid, WTERMSIG(status), strsignal(WTERMSIG(status)),
			(WCOREDUMP(status) ? ", core dumped" : ""));
	    }
	}
    }
}

static int spawn_children(void)
{
    pid_t pid;
    int err = 0;
    int cpu;
    long ncpus = sysconf(_SC_NPROCESSORS_ONLN);

    children = (pid_t *)malloc(sizeof(pid_t) * nthreads);
    if (!children)
    {
	fprintf(stderr, "%s: out of memory\n", argv0);
	return -ENOMEM;
    }

    while (nchildren < nthreads)
    {
	pid = fork();
	if (pid < 0)
	{
	    err = -errno;
	    perror("fork");
	    break;
	}
	if (pid == 0)
	{
	    /* child */
	    cpu = nchildren % ncpus;
	    bind_to_cpu(cpu);
	    asprintf(&argv0, "%s[pid %d cpu %d]", argv0, (int)getpid(), cpu);
	    fprintf(stderr, "%s: child %d ready\n",
		    argv0, nchildren);
	    return 1; /* continue on to main message loop */
	}
	else
	{
	    /* parent */
	    children[nchildren++] = pid;
	}
    }

    if (nchildren)
    {
	if (err)
	    kill_children();
	wait_for_children();
    }
    if (children)
	free(children);
    return err;
}

static void
doit(void)
{
    FILE *fp;
    const char *cache_name = "sgi.test";
    int len;
    char *buf;
    int loop_flag;
    int buf_size = 4096;
    char filename[256];

    if ((buf = malloc(buf_size)) == NULL)
    {
	fprintf(stderr, "%s: out of memory, exiting\n", argv0);
	exit(1);
    }

    snprintf(filename, sizeof(filename),
	     "/proc/net/rpc/%s/channel", cache_name);

    if ((fp = fopen(filename, "r+")) == NULL)
    {
	perror(filename);
	exit(1);
    }

    loop_flag = 1;
    if (nthreads > 1)
	loop_flag = spawn_children();

    if (loop_flag == 1)
    {
	while ((len = read_message(fp, buf, buf_size)) >= 0)
	    handle_message(fp, buf, len);

	if (len < 0)
	    perror(filename);
    }

    fclose(fp);
}


int
main(int argc, char **argv)
{
    parse_args(argc, argv);

    doit();

    return 0;
}


--------------070806030004090902060808--
