From: "Mark Hartwig" <hartwigm@BoulderCustomHomes.com>
Subject: Re: nfs and xfs on 1.1T partition
Date: Wed, 15 Jan 2003 12:52:27 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1109.128.138.134.61.1042653147.squirrel@www.bouldercustomhomes.com>
References: <m3y95ngdqs.fsf@zsu.sush.org>
Reply-To: hartwigm@BoulderCustomHomes.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [66.70.114.40] (helo=www.promopipe.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Ys6m-0001pZ-00
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 10:17:48 -0800
To: <mi@imarko.dhs.org>
In-Reply-To: <m3y95ngdqs.fsf@zsu.sush.org>
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

Istvan, thanks for the response.  All other disk-intensive processes cause
the xfs partition no problems, other than NFS.  I can scp, rcp, rsh, and
rsync to and from the XFS partition perfectly.  I can also copy large files
to and from it locally with no problems.  The server seems to hang only
when I transfer large files via NFS to or from the xfs partition.  I can,
for example, cp -R a directory that is 1G to the xfs partition as long as
each file within the directory is less than about 200M.  However, a cp of a
single file that is 260M freezes the server every time.
Thanks for any insight you can give me.


> "Mark Hartwig" <hartwigm@BoulderCustomHomes.com> writes:
>
>> Hello all, I'm having a problem with nfsd (from Mandrake 9.0 install
>> 2.4.19 kernel) on xfs partitions.  I am running an IDE RAID5 with
>> 3Ware's Escalade 7500 controller. The xfs partition as 1.1T.  I can
>> transfer large ammounts of small files on to the xfs partition without
>> any problems, but as soon as I try to transfer a large file to the
>> partition, the entire server freezes when about 200 megs have been
>> transfered.  At this point, the server is completely frozen and can
>> only be restarted manually.  I can, however, transfer large files to
>> the same server, but on to a smaller 100G ext3 partition.  Ideally, I
>> would like to find a work around the issue without having to re-format
>> the entire RAID.  Any help would be greatly appreciated.
>
> Mark,
>
> Try narrowing it down a bit. Are you able to reproduce the hang when
> you copy file without using NFS, for example using rsync? How about
> just using something like dd if=/dev/zero of=//file/on/xfs/partition?
>
> If yes, you might want to ask on the XFS list or see if it's related to
> the hardware you use.
>
> For what it's worth, I have 3 NFS servers using XFS, each with 340GB
> SCSI hardware RAID disk and they have been running for a few months now
> with little problems. With older kernels (around 2.2.18 or 19pre) I had
> crashes once every few weeks but with 2.4.20 so far no problems *knock
> on wood*
>
> --
> 	Istvan


-- 
Mark Hartwig
Boulder Custom Homes
720-530-4102
hartwigm@BoulderCustomHomes.com




-------------------------------------------------------
This SF.NET email is sponsored by: A Thawte Code Signing Certificate 
is essential in establishing user confidence by providing assurance of 
authenticity and code integrity. Download our Free Code Signing guide:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0028en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
