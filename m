From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Trying to determine why my NFS connection goes away
Date: Sat, 16 Jun 2007 11:06:04 -0400
Message-ID: <1182006364.26143.1.camel@heimdal.trondhjem.org>
References: <bd9320b30706141625l6ceb9c73j22a46cf115ca78cd@mail.gmail.com>
	<1181874951.15174.15.camel@heimdal.trondhjem.org>
	<bd9320b30706142333h539215b4jd3c062c4ed666e8f@mail.gmail.com>
	<1181915360.6135.7.camel@heimdal.trondhjem.org>
	<bd9320b30706151532uaa16444q55b58d5c109b7c21@mail.gmail.com>
	<1181966629.6135.27.camel@heimdal.trondhjem.org>
	<bd9320b30706152357q64fdceaducac9cf8edb173a9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: mike <mike503@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HzZqu-0003Uy-4E
	for nfs@lists.sourceforge.net; Sat, 16 Jun 2007 08:06:13 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+px2Ehe6Zulyu7X3zgg02iFb1/jwRClP4=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HzZqv-0006wT-Qj
	for nfs@lists.sourceforge.net; Sat, 16 Jun 2007 08:06:15 -0700
In-Reply-To: <bd9320b30706152357q64fdceaducac9cf8edb173a9@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-06-15 at 23:57 -0700, mike wrote:
> On 6/15/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > Did you check that the above parameters are indeed set in /proc/mounts?
> 
> okay i am having a weird issue.
> 
> it is totally ignoring the timeo=XXX parameter in fstab, and even
> manually mounting:
> 
> [root@web03 /]# mount -t nfs -o timeo=600 raid01:/home /home
> 
> [root@web03 /]# mount
> raid01:/home on /local/home type nfs (rw,timeo=600,addr=192.168.1.151)
> 
> [root@web03 /]# cat /proc/mounts
> raid01:/home /local/home nfs
> rw,vers=3,rsize=16384,wsize=16384,hard,intr,nolock,proto=tcp,timeo=10,retrans=2,sec=sys,addr=raid01
> 0 0
> 
> is there some sort of weird caching or something i should be aware
> about? if i do not have timeo defined in fstab, it still has the
> timeo=10, if i define it as 600, it still keeps it as 10. i didn't
> even define tcp on the command line above and it kept the old
> settings...
> 
> i suppose if i can figure out why this is ignoring my requests then i
> can try to configure it to have the longer timeouts, etc...

You've got the same filesystem mounted somewhere else on the system and
so the NFS client will reuse the superblock from the other mount.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
