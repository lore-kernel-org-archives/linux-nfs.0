From: Dan Kegel <dkegel@ixiacom.com>
Subject: Re: more statd segfault
Date: Fri, 12 Sep 2003 13:21:09 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F622AB5.3010501@ixiacom.com>
References: <3F5CDF7D.2070608@hq.newdream.net>	<3F6129E3.6040604@newdream.net> <16225.27156.281198.45769@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: michael <michael@newdream.net>, NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19xuYC-0001Eq-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Sep 2003 13:29:52 -0700
Received: from 64-60-75-69.cust.telepacific.net ([64.60.75.69] helo=racerx.ixiacom.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19xuYC-0001Vd-5g
	for nfs@lists.sourceforge.net; Fri, 12 Sep 2003 13:29:52 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16225.27156.281198.45769@notabene.cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Neil Brown wrote:
> On Thursday September 11, michael@newdream.net wrote:
> 
>>I finally tracked down the statd segfault that had been plaguing me for 
>>sometime.
>>
>>statd calls sunrpc code which is in libc on debian. this code loops 
>>through all possible file descriptors and in my case if the number of 
>>fds per process is set higher then 8096 it segfaults.
> 
> 
> Well done.
> I have just applied a patch to statd and mountd in nfs-utils so that
> it forces the fd limit down to FD_SETSIZE if it is above that.  This
> appears to effectively work around what is really a libc bug (I
> think).
> 
> Have you reported it to the glibc maintainers?

I was curious, so I grepped for references to fd_set and FD_SETSIZE in glibc-2.3.2.
Looks like the rpc code actually exports an fd_set to the world!
Sad to have FD_SETSIZE show up in the interface like that.

(Looks like H.J. Lu had some interest in this code; see
http://sources.redhat.com/ml/libc-alpha/2001-05/msg00071.html)

Here are the hits of interest.

glibc-2.3.2/ChangeLog.11:       [_LIBC]: Fully reinstate the code that avoids the FD_SETSIZE limit
glibc-2.3.2/ChangeLog.12:       (rpc_thread_multi, __rpc_thread_svc_fdset, __rpc_thread_createerr,
glibc-2.3.2/ChangeLog.12:       * include/rpc/rpc.h: Remove svc_fdset, rpc_createerr, svc_pollfd, and
glibc-2.3.2/ChangeLog.12:       * sunrpc/rpc/rpc.h: Declare __rpc_thread_svc_fdset,
glibc-2.3.2/ChangeLog.12:       Define svc_fdset, get_rpc_createerr, svc_pollfd, and
glibc-2.3.2/ChangeLog.12:       Define __rpc_thread_svc_fdset, __rpc_thread_createerr,
glibc-2.3.2/ChangeLog.12:       * sunrpc/Versions [libc] (GLIBC_2.2.3): Export  __rpc_thread_svc_fdset,
glibc-2.3.2/FAQ.in:only place where OPEN_MAX and FD_SETSIZE is really needed in the library
glibc-2.3.2/FAQ.in:itself is the size of fd_set which is used by select.
glibc-2.3.2/FAQ.in:limits imposed by the `fd_set' type.  Instead all places where the
glibc-2.3.2/FAQ.in:prominent example is `struct fd_set'.
glibc-2.3.2/INTERFACE:svc_fdset                 svc_fdset
glibc-2.3.2/include/rpc/rpc.h:  fd_set          svc_fdset_s;            /* Global, rpc_common.c */
glibc-2.3.2/include/rpc/rpc.h:libc_hidden_proto (__rpc_thread_svc_fdset)
glibc-2.3.2/include/rpc/svc.h:extern void svc_getreqset_internal (fd_set *__readfds) attribute_hidden;
glibc-2.3.2/sunrpc/Versions:    rpc_createerr; svc_fdset; svcauthdes_stats;
glibc-2.3.2/sunrpc/Versions:    __rpc_thread_svc_fdset; __rpc_thread_createerr;
glibc-2.3.2/sunrpc/rpc/rpc.h:extern fd_set *__rpc_thread_svc_fdset (void) __attribute__ ((__const__));
glibc-2.3.2/sunrpc/rpc/rpc.h:#define svc_fdset (*__rpc_thread_svc_fdset ())
glibc-2.3.2/sunrpc/rpc/svc.h:extern fd_set svc_fdset;
glibc-2.3.2/sunrpc/rpc/svc.h:#define svc_fds svc_fdset.fds_bits[0]      /* compatibility */
glibc-2.3.2/sunrpc/rpc/svc.h:extern void svc_getreqset (fd_set *__readfds) __THROW;
glibc-2.3.2/sunrpc/rpc_common.c:#undef svc_fdset
glibc-2.3.2/sunrpc/rpc_common.c:fd_set svc_fdset;
glibc-2.3.2/sunrpc/rpc_svcout.c:  f_print (fout, "\t\textern fd_set svc_fdset;\n");
glibc-2.3.2/sunrpc/rpc_svcout.c:  f_print (fout, "\t\t\tif (FD_ISSET(i, &svc_fdset))\n");
glibc-2.3.2/sunrpc/rpc_thread.c:#undef svc_fdset
glibc-2.3.2/sunrpc/rpc_thread.c:fd_set *
glibc-2.3.2/sunrpc/rpc_thread.c:__rpc_thread_svc_fdset (void)
glibc-2.3.2/sunrpc/rpc_thread.c:                return &svc_fdset;
glibc-2.3.2/sunrpc/rpc_thread.c:        return &tvp->svc_fdset_s;
glibc-2.3.2/sunrpc/rpc_thread.c:libc_hidden_def (__rpc_thread_svc_fdset)
glibc-2.3.2/sunrpc/svc.c:      if (sock < FD_SETSIZE)
glibc-2.3.2/sunrpc/svc.c:       FD_SET (sock, &svc_fdset);
glibc-2.3.2/sunrpc/svc.c:      if (sock < FD_SETSIZE)
glibc-2.3.2/sunrpc/svc.c:       FD_CLR (sock, &svc_fdset);
glibc-2.3.2/sunrpc/svc.c:  fd_set readfds;
glibc-2.3.2/sunrpc/svc.c:svc_getreqset (fd_set *readfds)
- Dan



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
