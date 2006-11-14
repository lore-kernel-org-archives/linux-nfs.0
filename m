From: Neil Brown <neilb@suse.de>
Subject: Re: NFS specifically slow
Date: Tue, 14 Nov 2006 14:44:48 +1100
Message-ID: <17753.15280.665323.354631@cse.unsw.edu.au>
References: <b03954e20611131441wd602331na2ecac03cf3c7578@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjpEG-0005dh-Ie
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 19:44:56 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GjpEG-0005l5-Bo
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 19:44:57 -0800
To: "Jeroen Maris" <jamaris@gmail.com>
In-Reply-To: message from Jeroen Maris on Monday November 13
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

On Monday November 13, jamaris@gmail.com wrote:
> Hey.
> I have a server with a raid5 array, consisting of 5 x 500 GB mounted as
> /directory.
> I export this directory in /etc/exports as "/array 192.168.1.2
> (rw,sync,no_root_squash)".
> On the client it is mounted with "server:/directory/ /directory nfs
> rw,rsize=8192,wsize=8192,timeo=14,intr,hard 0 0"
> 
> Read performance is good; approximately 30 MB/s.
> Write performance is very poor; approximately 5 MB/s.

Hmmm... If I understand correctly, you get slow performance when
writing to this raid5 and slow performance when reading from an ntfs
local filesystem - yes?
I suspect there are separate problems.
I would suggest testing everything independently, reading from
/dev/full and writing to /dev/null, e.g. with 'dd'.

Writing to a raid5 tends to be slow, especially lots of small sync
writes as NFS requires.  5 MB/s seems a bit slow - assuming you have
gigabit ethernet (it is reason for 100Mbit ethernet).

What is the local write speed to the raid5 array like?

Can you do a series for tests like:
   dd if=/dev/full of=BIG bs=1024k count=100

on various filesystems both locally and over NFS.  Maybe that will
show a clearer pattern.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
