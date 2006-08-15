From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 2/5] NLM failover - per fs grace period
Date: Tue, 15 Aug 2006 14:32:45 -0400
Message-ID: <44E2134D.7000809@redhat.com>
References: <1155535221.3416.26.camel@localhost.localdomain>
	<1155570281.5664.84.camel@localhost> <44E09DDA.9070302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GD3jw-0008DZ-QV
	for nfs@lists.sourceforge.net; Tue, 15 Aug 2006 11:34:12 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GD3jw-0003vo-1V
	for nfs@lists.sourceforge.net; Tue, 15 Aug 2006 11:34:13 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <44E09DDA.9070302@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

There were few replies emails that didn't arrive at nfs list last week 
but got archived in:

* why switching to fsid
https://www.redhat.com/archives/cluster-devel/2006-August/msg00090.html

* cluster script failover sequence)
https://www.redhat.com/archives/cluster-devel/2006-August/msg00087.html

To help people understand the patch logic, the following is a sample 
failover flow:

Assume we have server_A and server_B. Server_A is a multi-home NFS 
server with two ip address 10.10.10.1 and 10.10.1.1 where:

shell> cat /etc/exports
/mnt/ext3/exports    *(fsid=1234,sync,rw)
/mnt/gfs1/exports    *(fsid=1236,sync,rw)

It is expected ext3 filesystem served by 10.10.1.1 and gfs served by 
10.10.10.1. If we ever want to move ext3 over to server_B, the sequence 
would be:

On server_A:
1. Tear down 10.10.1.1
2. Un-export ext3 exports
3. echo 1234 > /proc/fs/nfsd/nlm_unlock
4. Umount ext3

On sever_B:
1. Mount ext3 fs
2. echo 1234 > /proc/fs/nfsd/nlm_set_igrace
3. Export ext3 exports
4. Bring up 10.10.1.1
5. Sending restricted reclaim notifications via 10.10.1.1

Step 5 is implemented based on the ha-callout program as described in 
"man rpc.statd".  What our cluster suite (user mode script) will do (if 
this patch set gets accepted) is to bring up rpc.statd on both servers 
with ha-callout program.
On server_A, the ha-callout program constructs two sm directories 
(sm-10.10.10.1 and sm-10.10.1.1) that can be accessed by both servers. 
This is normally done by placing the directories on the filesystem that 
will get moved over. The original /var/lib/nfs/statd/sm stays in its 
default place in case of server_A ends up with a real reboot (or crash). 
When server_B takes over, it sends out an one-time notice to all the 
clients that has entries in sm-10.10.1.1 directory.

Note that the code of ha-callout program (will be done by our cluster 
suite) actually can be integrated into statd within nfs-utils package. 
However, I would like to keep the changes made into mainline nfs code as 
miminum as possible at this moment.

-- Wendy





-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
