From: Jean-Noel BOUVIER <Jean-Noel.Bouvier@imag.fr>
Subject: Re: poor nfs performance & hangs with latest kernels
Date: Mon, 5 Mar 2007 14:30:10 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0703051055470.4947@vercors.imag.fr>
References: <45D9B915.2010305@hq.vsaa.lv>
	<17882.49990.799201.335846@notabene.brown>
	<45DC4BB3.7090706@imag.fr> <17884.65504.902843.745554@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: rich@hq.vsaa.lv, nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HODID-0001NG-4e
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 05:31:57 -0800
Received: from imag.imag.fr ([129.88.30.1])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HODIA-00089I-PM
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 05:31:56 -0800
In-Reply-To: <17884.65504.902843.745554@notabene.brown>
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

Hello,

On Thu, 22 Feb 2007, Neil Brown wrote:

> On Wednesday February 21, jean-noel.bouvier@imag.fr wrote:
>> Hello,
>>
>> I encounter the same NFS bad performance for kernels newer than 2.6.16.31
>>
>> Tests : tar -xvf linux-2.4.32.tar
>>
>> Environment :
>> - client 2.6.16.31
>> - client mounts a XFS file system through NFS on a remote machine with
>> options =3D rw,tcp,intr
>> - server : exporting file system with options =3D rw,sync,insecure
>>
>> Results : (according to server kernel version)
>> 2.6.15.7 =3D> 1 minute 10 sec
>> 2.6.16.31 =3D> 1 minute 02 sec
>> 2.6.17.14 =3D> 15 minutes
>> 2.6.18.3 =3D> 15 minutes
>
> Those look like very strong results....
>
> Could you try this patch on one of the later kernels and see if it
> helps?

Unfortunately, this patch did not enable better performance :

Linux 2.6.16.31/XFS+NFS =3D> 1min (4 process with status S+S+R+D)
Linux 2.6.17.14/XFS+NFS =3D> 15min (2 process with status S+D)
Linux 2.6.17.14/XFS+NFS + patch =3D> 14min51 (2 process with status S+D)

But, I also tried the same tests on a XFS and EXT3 file systems but =

***without*** NFS, just to be sure :

Linux 2.6.16.31/XFS =3D> 0 min 12s | Linux 2.6.16.31/EXT3 =3D> 0 min 07s
Linux 2.6.17.14/XFS =3D> 0 min 51s | Linux 2.6.17.14/EXT3 =3D> 0 min 04s
Linux 2.6.18-4/XFS =3D>  0 min 57s | Linux 2.6.18-4/EXT3 =3D>  0 min 02s

So I am afraid the problem is rather bound to XFS and >2.6.16 kernels =

than NFS.
Do you agree or do you want me to do other tests to be sure NFS is not =

concerned ?

> Otherwise we might have do to the 'git bisect' thing to find the
> offending patch.
>
> Thanks,
> NeilBrown

Thanks,
-- =

Jean-No=EBl BOUVIER

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
