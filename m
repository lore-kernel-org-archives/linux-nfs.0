From: Olaf Kirch <okir@suse.de>
Subject: Re: NSM lock recovery fails too often
Date: Tue, 9 Mar 2004 11:57:23 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040309105723.GB20391@suse.de>
References: <482A3FA0050D21419C269D13989C61130435DD1C@lavender-fe.eng.netapp.com> <20040309105607.GA20391@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="GRPZ8SYKNexpdSJ7"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0f48-0005b6-L0
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 03:06:28 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B0evN-0008P1-PD
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 02:57:26 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <20040309105607.GA20391@suse.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--GRPZ8SYKNexpdSJ7
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

Here's the promised sm-notify utility.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 

--GRPZ8SYKNexpdSJ7
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename="sm-notify.c"

/*
 * Send NSM notify calls to all hosts listed in /var/lib/sm
 *
 * Copyright (C) 2004 Olaf Kirch <okir@suse.de>
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/poll.h>
#include <sys/param.h>
#include <sys/syslog.h>
#include <arpa/inet.h>
#include <dirent.h>
#include <time.h>
#include <stdio.h>
#include <getopt.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdarg.h>

#ifndef BASEDIR
#define BASEDIR		"/var/lib/nfs"
#endif

#define _SM_STATE_PATH	BASEDIR "/state"
#define	_SM_DIR_PATH	BASEDIR "/sm"
#define	_SM_BAK_PATH	_SM_DIR_PATH ".bak"

#define NSM_PROG	100024
#define NSM_PROGRAM	100024
#define NSM_VERSION	1
#define NSM_TIMEOUT	2
#define NSM_NOTIFY	6
#define NSM_MAX_TIMEOUT	120	/* don't make this too big */
#define MAXMSGSIZE	256

typedef struct sockaddr_storage nsm_address;

struct nsm_host {
	struct nsm_host *	next;
	char *			name;
	char *			path;
	nsm_address		addr;
	time_t			last_used;
	time_t			send_next;
	unsigned int		timeout;
	unsigned int		retries;
	unsigned int		xid;
};

static char		nsm_hostname[256];
static uint32_t		nsm_state;
static int		opt_debug = 0;
static int		opt_quiet = 0;
static int		opt_update_state = 1;
static unsigned int	opt_max_retry = 15 * 60;
static int		log_syslog = 0;

static unsigned int	nsm_get_state(int);
static void		notify(void);
static void		notify_host(int, struct nsm_host *);
static void		recv_reply(int);
static void		backup_hosts(const char *, const char *);
static void		get_hosts(const char *);
static void		insert_host(struct nsm_host *);
struct nsm_host *	find_host(uint32_t);
static int		addr_parse(int, const char *, nsm_address *);
static int		addr_get_port(nsm_address *);
static void		addr_set_port(nsm_address *, int);
void			nsm_log(int fac, const char *fmt, ...);

static struct nsm_host *	hosts = NULL;

int
main(int argc, char **argv)
{
	int	c;

	while ((c = getopt(argc, argv, "dqm:n")) != -1) {
		switch (c) {
		case 'd':
			opt_debug++;
			break;
		case 'm':
			opt_max_retry = atoi(optarg) * 60;
			break;
		case 'n':
			opt_update_state = 0;
			break;
		case 'q':
			opt_quiet = 1;
			break;
		default:
			goto usage;
		}
	}

	if (optind < argc) {
usage:		fprintf(stderr, "sm-notify [-d]\n");
		return 1;
	}

	if (gethostname(nsm_hostname, sizeof(nsm_hostname)) < 0) {
		perror("gethostname");
		return 1;
	}

	nsm_state = nsm_get_state(opt_update_state);

	backup_hosts(_SM_DIR_PATH, _SM_BAK_PATH);
	get_hosts(_SM_BAK_PATH);

	if (hosts == NULL && !opt_quiet)
		printf("No hosts to notify, done\n");

	if (!opt_debug) {
		printf("Backgrounding to notify hosts...\n");
		if (daemon(0, 0) < 0) {
			perror("daemon");
			return 1;
		}
		openlog("sm-notify", LOG_PID, LOG_DAEMON);
		log_syslog = 1;

		close(0);
		close(1);
		close(2);
	}

	notify();

	if (hosts) {
		struct nsm_host	*hp;

		while ((hp = hosts) != 0) {
			hosts = hp->next;
			nsm_log(LOG_NOTICE,
				"Unable to notify %s, giving up",
				hp->name);
		}
		return 1;
	}

	return 0;
}

/*
 * Notify hosts
 */
void
notify(void)
{
	time_t	failtime = 0;
	int	sock = -1;

	sock = socket(AF_INET, SOCK_DGRAM, 0);
	if (sock < 0) {
		perror("socket");
		exit(1);
	}
	fcntl(sock, F_SETFL, O_NONBLOCK);

	if (opt_max_retry)
		failtime = time(NULL) + opt_max_retry;

	while (hosts) {
		struct pollfd	pfd;
		time_t		now = time(NULL);
		unsigned int	sent = 0;
		struct nsm_host	*hp;
		long		wait;

		if (failtime && now >= failtime)
			break;

		while ((wait = hosts->send_next - now) <= 0) {
			/* Never send more than 10 packets at once */
			if (sent++ >= 10)
				break;

			/* Remove queue head */
			hp = hosts;
			hosts = hp->next;

			notify_host(sock, hp);

			/* Set the timeout for this call, using an
			   exponential timeout strategy */
			wait = hp->timeout;
			if ((hp->timeout <<= 1) > NSM_MAX_TIMEOUT)
				hp->timeout = NSM_MAX_TIMEOUT;
			hp->send_next = now + wait;
			hp->retries++;

			insert_host(hp);
		}

		nsm_log(LOG_DEBUG, "Host %s due in %ld seconds",
				hosts->name, wait);

		pfd.fd = sock;
		pfd.events = POLLIN;

		wait *= 1000;
		if (wait < 100)
			wait = 100;
		if (poll(&pfd, 1, wait) != 1)
			continue;

		recv_reply(sock);
	}
}

/*
 * Send notification to a single host
 */
void
notify_host(int sock, struct nsm_host *host)
{
	static unsigned int	xid = 0;
	nsm_address		dest;
	uint32_t		msgbuf[MAXMSGSIZE], *p;
	unsigned int		len;

	if (!xid)
		xid = getpid() + time(NULL);
	if (!host->xid)
		host->xid = xid++;

	memset(msgbuf, 0, sizeof(msgbuf));
	p = msgbuf;
	*p++ = htonl(host->xid);
	*p++ = 0;
	*p++ = htonl(2);

	/* If we retransmitted 4 times, reset the port to force
	 * a new portmap lookup (in case statd was restarted)
	 */
	if (host->retries >= 4) {
		addr_set_port(&host->addr, 0);
		host->retries = 0;
	}

	dest = host->addr;
	if (addr_get_port(&dest) == 0) {
		/* Build a PMAP packet */
		nsm_log(LOG_DEBUG, "Sending portmap query to %s", host->name);

		addr_set_port(&dest, 111);
		*p++ = htonl(100000);
		*p++ = htonl(2);
		*p++ = htonl(3);

		/* Auth and verf */
		*p++ = 0; *p++ = 0;
		*p++ = 0; *p++ = 0;

		*p++ = htonl(NSM_PROGRAM);
		*p++ = htonl(NSM_VERSION);
		*p++ = htonl(IPPROTO_UDP);
		*p++ = 0;
	} else {
		/* Build an SM_NOTIFY packet */
		nsm_log(LOG_DEBUG, "Sending SM_NOTIFY to %s", host->name);

		*p++ = htonl(NSM_PROGRAM);
		*p++ = htonl(NSM_VERSION);
		*p++ = htonl(NSM_NOTIFY);

		/* Auth and verf */
		*p++ = 0; *p++ = 0;
		*p++ = 0; *p++ = 0;

		/* state change */
		len = strlen(nsm_hostname);
		*p++ = htonl(len);
		memcpy(p, nsm_hostname, len);
		p += (len + 3) >> 2;
		*p++ = htonl(nsm_state);
	}
	len = (p - msgbuf) << 2;

	sendto(sock, msgbuf, len, 0, (struct sockaddr *) &dest, sizeof(dest));
}

/*
 * Receive reply from remote host
 */
void
recv_reply(int sock)
{
	struct nsm_host	*hp;
	uint32_t	msgbuf[MAXMSGSIZE], *p, *end;
	uint32_t	xid;
	int		res;

	res = recv(sock, msgbuf, sizeof(msgbuf), 0);
	if (res < 0)
		return;

	nsm_log(LOG_DEBUG, "Received packet...");

	p = msgbuf;
	end = p + (res >> 2);
	
	xid = ntohl(*p++);
	if (*p++ != htonl(1)	/* must be REPLY */
	 || *p++ != htonl(0)	/* must be ACCEPTED */
	 || *p++ != htonl(0)	/* must be NULL verifier */
	 || *p++ != htonl(0)
	 || *p++ != htonl(0))	/* must be SUCCESS */
		return;

	/* Before we look at the data, find the host struct for
	   this reply */
	if ((hp = find_host(xid)) == NULL)
		return;

	if (addr_get_port(&hp->addr) == 0) {
		/* This was a portmap request */
		unsigned int	port;

		port = ntohl(*p++);
		if (p > end)
			goto fail;

		hp->send_next = time(NULL);
		if (port == 0) {
			/* No binding for statd. Delay the next
			 * portmap query for max timeout */
			nsm_log(LOG_DEBUG, "No statd on %s", hp->name);
			hp->timeout = NSM_MAX_TIMEOUT;
			hp->send_next += NSM_MAX_TIMEOUT;
		} else {
			addr_set_port(&hp->addr, port);
			if (hp->timeout >= NSM_MAX_TIMEOUT / 4)
				hp->timeout = NSM_MAX_TIMEOUT / 4;
		}
		hp->xid = 0;
	} else {
		/* Successful NOTIFY call. Server returns void,
		 * so nothing we need to do here (except
		 * check that we didn't read past the end of the
		 * packet)
		 */
		if (p <= end) {
			nsm_log(LOG_DEBUG, "Host %s notified successfully", hp->name);
			unlink(hp->path);
			free(hp->name);
			free(hp->path);
			free(hp);
			return;
		}
	}

fail:	/* Re-insert the host */
	insert_host(hp);
}

/*
 * Back up all hosts from the sm directory to sm.bak
 */
static void
backup_hosts(const char *dirname, const char *bakname)
{
	struct dirent	*de;
	DIR		*dir;

	if (!(dir = opendir(dirname))) {
		perror(dirname);
		return;
	}

	while ((de = readdir(dir)) != NULL) {
		char	src[1024], dst[1024];

		if (de->d_name[0] == '.')
			continue;

		snprintf(src, sizeof(src), "%s/%s", dirname, de->d_name);
		snprintf(dst, sizeof(dst), "%s/%s", bakname, de->d_name);
		if (rename(src, dst) < 0) {
			nsm_log(LOG_WARNING,
				"Failed to rename %s -> %s: %m",
				src, dst);
		}
	}
	closedir(dir);
}

/*
 * Get all entries from sm.bak and convert them to host names
 */
static void
get_hosts(const char *dirname)
{
	struct nsm_host	*host;
	struct dirent	*de;
	DIR		*dir;

	if (!(dir = opendir(dirname))) {
		perror(dirname);
		return;
	}

	host = NULL;
	while ((de = readdir(dir)) != NULL) {
		struct stat	stb;
		char		path[1024];

		if (de->d_name[0] == '.')
			continue;
		if (host == NULL)
			host = calloc(1, sizeof(*host));

		snprintf(path, sizeof(path), "%s/%s", dirname, de->d_name);
		if (!addr_parse(AF_INET, de->d_name, &host->addr)
		 && !addr_parse(AF_INET6, de->d_name, &host->addr)) {
			nsm_log(LOG_WARNING,
				"%s doesn't seem to be a valid address, skipped",
				de->d_name);
			unlink(path);
			continue;
		}

		if (stat(path, &stb) < 0)
			continue;
		host->last_used = stb.st_mtime;
		host->timeout = NSM_TIMEOUT;
		host->path = strdup(path);
		host->name = strdup(de->d_name);

		insert_host(host);
		host = NULL;
	}
	closedir(dir);

	if (host)
		free(host);
}

/*
 * Insert host into sorted list
 */
void
insert_host(struct nsm_host *host)
{
	struct nsm_host	**where, *p;

	where = &hosts;
	while ((p = *where) != 0) {
		/* Sort in ascending order of timeout */
		if (host->send_next < p->send_next)
			break;
		/* If we have the same timeout, put the
		 * most recently used host first.
		 * This makes sure that "recent" hosts
		 * get notified first.
		 */
		if (host->send_next == p->send_next
		 && host->last_used > p->last_used)
			break;
		where = &p->next;
	}

	host->next = *where;
	*where = host;
}

/*
 * Find host given the XID
 */
struct nsm_host *
find_host(uint32_t xid)
{
	struct nsm_host	**where, *p;

	where = &hosts;
	while ((p = *where) != 0) {
		if (p->xid == xid) {
			*where = p->next;
			return p;
		}
		where = &p->next;
	}
	return NULL;
}


/*
 * Retrieve the current NSM state
 */
unsigned int
nsm_get_state(int update)
{
	char		newfile[PATH_MAX];
	int		fd, state;

	if ((fd = open(_SM_STATE_PATH, O_RDONLY)) < 0) {
		if (!opt_quiet) {
			nsm_log(LOG_WARNING, "%s: %m", _SM_STATE_PATH);
			nsm_log(LOG_WARNING, "Creating %s, set initial state 1",
				_SM_STATE_PATH);
		}
		state = 1;
		update = 1;
	} else {
		if (read(fd, &state, sizeof(state)) != sizeof(state)) {
			nsm_log(LOG_WARNING,
				"%s: bad file size, setting state = 1",
				_SM_STATE_PATH);
			state = 1;
			update = 1;
		} else {
			if (!(state & 1))
				state += 1;
		}
		close(fd);
	}

	if (update) {
		state += 2;
		snprintf(newfile, sizeof(newfile),
				"%s.new", _SM_STATE_PATH);
		if ((fd = open(newfile, O_CREAT|O_WRONLY, 0644)) < 0) {
			nsm_log(LOG_WARNING, "Cannot create %s: %m", newfile);
			exit(1);
		}
		if (write(fd, &state, sizeof(state)) != sizeof(state)) {
			nsm_log(LOG_WARNING,
				"Failed to write state to %s", newfile);
			exit(1);
		}
		close(fd);
		if (rename(newfile, _SM_STATE_PATH) < 0) {
			nsm_log(LOG_WARNING,
				"Cannot create %s: %m", _SM_STATE_PATH);
			exit(1);
		}
		sync();
	}

	return state;
}

/*
 * Address handling utilities
 */
static int
addr_parse(int af, const char *name, nsm_address *addr)
{
	void	*ptr;

	if (af == AF_INET)
		ptr = &((struct sockaddr_in *) addr)->sin_addr;
	else if (af == AF_INET6)
		ptr = &((struct sockaddr_in6 *) addr)->sin6_addr;
	else
		return 0;
	if (inet_pton(af, name, ptr) <= 0)
		return 0;
	((struct sockaddr *) addr)->sa_family = af;
	return 1;
}

int
addr_get_port(nsm_address *addr)
{
	switch (((struct sockaddr *) addr)->sa_family) {
	case AF_INET:
		return ntohs(((struct sockaddr_in *) addr)->sin_port);
	case AF_INET6:
		return ntohs(((struct sockaddr_in6 *) addr)->sin6_port);
	}
	return 0;
}

static void
addr_set_port(nsm_address *addr, int port)
{
	switch (((struct sockaddr *) addr)->sa_family) {
	case AF_INET:
		((struct sockaddr_in *) addr)->sin_port = htons(port);
		break;
	case AF_INET6:
		((struct sockaddr_in6 *) addr)->sin6_port = htons(port);
	}
}

/*
 * Log a message
 */
void
nsm_log(int fac, const char *fmt, ...)
{
	va_list	ap;

	if (fac == LOG_DEBUG && !opt_debug)
		return;

	va_start(ap, fmt);
	if (log_syslog)
		vsyslog(fac, fmt, ap);
	else {
		vfprintf(stderr, fmt, ap);
		fputs("\n", stderr);
	}
	va_end(ap);
}

--GRPZ8SYKNexpdSJ7--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
