From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: NFS write errors
Date: Wed, 13 Oct 2004 13:39:25 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1097699964.8133.2940.camel@tesuji.nac.uci.edu>
References: <1097686177.8133.2915.camel@tesuji.nac.uci.edu>
	 <416D8C32.8000801@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CHpuN-00014D-J2
	for nfs@lists.sourceforge.net; Wed, 13 Oct 2004 13:39:39 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CHpuM-0008DJ-Ou
	for nfs@lists.sourceforge.net; Wed, 13 Oct 2004 13:39:39 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <416D8C32.8000801@RedHat.com>
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

On Wed, 2004-10-13 at 13:12, Steve Dickson wrote:
> Dan Stromberg wrote:
> 
> >We are occasionally getting NFS write errors when writing terrabytes of
> >data from an AIX 5.1 system to an RHEL 3 system, using the version of
> >in-kernel NFS that comes with RHEL 3.  We're using 8k rsize, 8k wsize,
> >nfs v3, and tcp presently, but this isn't written in stone.
> >  
> >
> What kind of errors? Is there anything in either /var/log/messages
> that talk about some error condition? What kernel are we talking about?
> 
> SteveD.

Both of the write errors I've documented were during a huge rsync.

The only error that looks at all relevant in /var/log/messages are:

Oct 11 14:44:37 esmft1 rpc.rquotad: No correct mountpoint specified.
Oct 11 14:44:37 esmft1 rpc.rquotad: Can't find filesystem mountpoint for
directo
ry /data/gfs044
Oct 11 14:44:37 esmft1 rpc.rquotad: No correct mountpoint specified.
Oct 11 14:44:37 esmft1 rpc.rquotad: Can't find filesystem mountpoint for
directo
ry /data/gfs045
Oct 11 14:44:37 esmft2-2 rpc.rquotad: Can't find filesystem mountpoint
for direc
tory /foo 
Oct 11 14:44:37 esmft1 rpc.rquotad: No correct mountpoint specified.
Oct 11 14:44:37 esmft2-2 rpc.rquotad: No correct mountpoint specified. 
Oct 11 14:44:37 esmft2-2 rpc.rquotad: Can't find filesystem mountpoint
for direc
tory /mnt/lustre 
Oct 11 14:44:37 esmft2-2 rpc.rquotad: No correct mountpoint specified. 

esmft2 is the relevant NFS server.  esmft1 is not germane, but it's
interesting that it had such similar errors.  The time of the failure
was 14:46 on Oct 11 - two minutes after these errors.

The other write error I documented had nothing at all relevant looking
in /var/log/messages.

The linux NFS server has:

[root@esmft2 log]# cat /etc/redhat-release 
Red Hat Enterprise Linux WS release 3 (Taroon Update 3)
[root@esmft2 log]# cat /proc/version 
Linux version 2.4.21-15.0.4.EL.lustre1.3.9.1 (root@esmft2) (gcc version
3.2.3 20030502 (Red Hat Linux 3.2.3-42)) #7 SMP Mon Sep 13 15:49:25 PDT
2004
[root@esmft2 log]# 

The Oct 11th write error had nothing relevant in AIX's errpt -a.  The
Oct 8th write error is no longer in errpt -a's data (?).

-- 
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
