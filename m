From: antonio@geto.net
Subject: mount point not recovering after NFS server comes back
Date: Thu, 17 Jul 2003 14:48:02 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0307171424440.22986-100000@www.geto.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from geto.net ([207.71.207.33] ident=qmailr)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19dGbf-0003HS-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Jul 2003 14:48:07 -0700
To: nfs@lists.sourceforge.net
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

Hi everybody -- I'm really hoping someone can push me in the right 
direction on this . . .

NFS server is a NetApp filer running OnTap 6.3.2
NFS clients are RedHat 9 boxes running linux 2.4.20.

We are using soft mounts with these options:
rw,soft,intr,nfsvers=3,wsize=32768,rsize=32768, \
proto=tcp,timeo=3,retrans=1,noac,sync

We are using these mount point options so that our application
(which constantly is writing to the NFS server) can detect
an NFS operation timeout after 0.9 seconds and fail over to local
disk to queue until the NFS server comes back.

Problem is -- is that is the NFS server is gone for any length of time,
the mount point doesn't "recover".  df -k hangs forever, I can't
re-mount the mount point, and any processes that attempt to stat
or otherwise access the mount point are shown as being in an 
"uninterruptable sleep" according to ps.

The only was I've been able to restore access to our mount point is to 
reboot the clients that are hung.  After enabling nfs/rpc debugging I'm 
seeing this in /var/log/messages after attempting an NFS operation:

Jul 17 14:40:04 ts_10_2_20_22 kernel: RPC: 47394 reserved req f7aca7c8 xid 
6e94a90f
Jul 17 14:40:04 ts_10_2_20_22 kernel: RPC: 47394 xprt_reserve returns 0
Jul 17 14:40:04 ts_10_2_20_22 kernel: RPC: 47395 xprt_reconnect f7aca000 
connected 0
Jul 17 14:40:04 ts_10_2_20_22 kernel: RPC: 47395 TCP write queue full


According to ltrace and strace, processes hang in one of the following 
locations:

__xstat64(3, "/corelog", 0x08058f74 <unfinished ...
stat64("/corelog",  <unfinished ...>
statfs("/corelog",  <unfinished ...>


Restarting nfslock and portmap have no effect.  Note that I can mount the 
same NFS share to a different location on the client and work from there 
-- but in order to restore access to the original mount point I have to 
reboot the server...

any ideas?









-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
