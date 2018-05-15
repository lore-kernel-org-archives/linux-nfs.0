Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:38874 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753683AbeEOPot (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2018 11:44:49 -0400
Received: by mail-qk0-f195.google.com with SMTP id b39-v6so531335qkb.5
        for <linux-nfs@vger.kernel.org>; Tue, 15 May 2018 08:44:49 -0700 (PDT)
Message-ID: <1526399086.3803.19.camel@redhat.com>
Subject: Re: [PATCH] Fix possible stack smash in
 nfs_idmap_read_and_verify_message
From: David Wysochanski <dwysocha@redhat.com>
To: Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Tue, 15 May 2018 11:44:46 -0400
In-Reply-To: <da9db571bbeb0e4e341859ab7cd160b9f0e5c0c7.camel@hammerspace.com>
References: <20180417201118.17841-1-dwysocha@redhat.com>
         <1526389606.3803.4.camel@redhat.com>
         <da9db571bbeb0e4e341859ab7cd160b9f0e5c0c7.camel@hammerspace.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2018-05-15 at 13:59 +0000, Trond Myklebust wrote:
> On Tue, 2018-05-15 at 09:06 -0400, David Wysochanski wrote:
> > On Tue, 2018-04-17 at 16:11 -0400, Dave Wysochanski wrote:
> > > In nfs_idmap_read_and_verify_message there is an unprotected
> > > sprintf
> > > that converts the __u32 'im_id' from struct idmap_msg to 'id_str'
> > > that is a stack variable of 'NFS_UINT_MAXLEN' (defined as 11).
> > > If a uid or gid value is > 2147483647 = 0x7fffffff we corrupt
> > > kernel memory by one byte and if CONFIG_CC_STACKPROTECTOR_STRONG
> > > is set we see a stack-protector panic as follows:
> > > 
> > > [11558053.616565] Kernel panic - not syncing: stack-protector:
> > > Kernel stack is corrupted in: ffffffffa05b8a8c
> > > 
> > > [11558053.639063] CPU: 6 PID: 9423 Comm: rpc.idmapd Tainted:
> > > G        W      ------------ T 3.10.0-514.el7.x86_64 #1
> > > [11558053.641990] Hardware name: Red Hat OpenStack Compute, BIOS
> > > 1.10.2-3.el7_4.1 04/01/2014
> > > [11558053.644462]  ffffffff818c7bc0 00000000b1f3aec1
> > > ffff880de0f9bd48 ffffffff81685eac
> > > [11558053.646430]  ffff880de0f9bdc8 ffffffff8167f2b3
> > > ffffffff00000010 ffff880de0f9bdd8
> > > [11558053.648313]  ffff880de0f9bd78 00000000b1f3aec1
> > > ffffffff811dcb03 ffffffffa05b8a8c
> > > [11558053.650107] Call Trace:
> > > [11558053.651347]  [<ffffffff81685eac>] dump_stack+0x19/0x1b
> > > [11558053.653013]  [<ffffffff8167f2b3>] panic+0xe3/0x1f2
> > > [11558053.666240]  [<ffffffff811dcb03>] ? kfree+0x103/0x140
> > > [11558053.682589]  [<ffffffffa05b8a8c>] ?
> > > idmap_pipe_downcall+0x1cc/0x1e0 [nfsv4]
> > > [11558053.689710]  [<ffffffff810855db>] __stack_chk_fail+0x1b/0x30
> > > [11558053.691619]  [<ffffffffa05b8a8c>]
> > > idmap_pipe_downcall+0x1cc/0x1e0 [nfsv4]
> > > [11558053.693867]  [<ffffffffa00209d6>] rpc_pipe_write+0x56/0x70
> > > [sunrpc]
> > > [11558053.695763]  [<ffffffff811fe12d>] vfs_write+0xbd/0x1e0
> > > [11558053.702236]  [<ffffffff810acccc>] ? task_work_run+0xac/0xe0
> > > [11558053.704215]  [<ffffffff811fec4f>] SyS_write+0x7f/0xe0
> > > [11558053.709674]  [<ffffffff816964c9>]
> > > system_call_fastpath+0x16/0x1b
> > > 
> > > Fix this by snprintf and a safe length based on sizeof(id_str).
> > > 
> > > Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> > > Reported-by: Stephen Johnston <sjohnsto@redhat.com>
> > > ---
> > >  fs/nfs/nfs4idmap.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
> > > index 22dc30a679a0..a8c663f8dd99 100644
> > > --- a/fs/nfs/nfs4idmap.c
> > > +++ b/fs/nfs/nfs4idmap.c
> > > @@ -627,7 +627,7 @@ static int
> > > nfs_idmap_read_and_verify_message(struct idmap_msg *im,
> > >  		if (strcmp(upcall->im_name, im->im_name) != 0)
> > >  			break;
> > >  		/* Note: here we store the NUL terminator too */
> > > -		len = sprintf(id_str, "%d", im->im_id) + 1;
> > > +		len = snprintf(id_str, sizeof(id_str), "%u", im-
> > > > im_id) + 1;
> > > 
> > >  		ret = nfs_idmap_instantiate(key, authkey, id_str,
> > > len);
> > >  		break;
> > >  	case IDMAP_CONV_IDTONAME:
> > 
> > 
> > I did not see any reply to this and we did have one customer hit this
> > which caused a considerable outage of many machines.  In essence once
> > this happened, it became a DoS on all machines using idmapping and
> > they
> > implemented a temporary workaround.
> > 
> > Anna / Trond - if you need me to improve the patch header or want
> > clarification or see a problem with it, please let me know.
> > 
> 
> If the value of NFS_UINT_MAXLEN is too small, then shouldn't we be
> increasing it? That would appear to be the real bug here.
> 
Sorry the patch header doesn't explain it well.  The %d usage with a
__u32 is the problem.  If we get a large enough value, the '-' sign
makes it a buffer overflow and the NULL overwrites one byte on the
stack.

Examples
crash> p (unsigned) (0x80000000)
$1 = 2147483648
crash> p (signed) (0x80000000)
$2 = -2147483648

So the unsigned max value uses 10 bytes plus a NULL, hence
NFS_UINT_MAXLEN of 11.


> I do agree that the "%d" should be changed to "%u", though. Isn't that
> sufficient to make the buffer large enough?
> 
> 
Yes you could just change the %d to %u in the sprintf, but the rest of
the code uses snprintf so that's why I chose it.

I'll also note there is nfs_map_numeric_to_string() that is called from
other locations, and we could call from here as well for consistency:
static int nfs_map_numeric_to_string(__u32 id, char *buf, size_t buflen)
{
	return snprintf(buf, buflen, "%u", id);
}


If you want, I could submit a v2 patch with an improved header and
this:

diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index 22dc30a..779411e0 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -343,7 +343,7 @@ static ssize_t nfs_idmap_lookup_name(__u32 id, const char *type, char *buf,
        int id_len;
        ssize_t ret;
 
-       id_len = snprintf(id_str, sizeof(id_str), "%u", id);
+       id_len = nfs_map_numeric_to_string(id, id_str, sizeof(id_str));
        ret = nfs_idmap_get_key(id_str, id_len, type, buf, buflen, idmap);
        if (ret < 0)
                return -EINVAL;
@@ -627,7 +627,7 @@ static int nfs_idmap_read_and_verify_message(struct idmap_msg *im,
                if (strcmp(upcall->im_name, im->im_name) != 0)
                        break;
                /* Note: here we store the NUL terminator too */
-               len = sprintf(id_str, "%d", im->im_id) + 1;
+               len = nfs_map_numeric_to_string(im->im_id, id_str, sizeof(id_str)) + 1;
                ret = nfs_idmap_instantiate(key, authkey, id_str, len);
                break;
        case IDMAP_CONV_IDTONAME:



