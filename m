From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: Stale File handles keep coming back
Date: Mon, 02 May 2005 08:24:27 +0200
Message-ID: <4275C79B.5000107@bio.ifi.lmu.de>
References: <1114463253.2487.73.camel@localhost.localdomain>	 <17006.13241.129839.558300@cse.unsw.edu.au>	 <1114554149.4470.5.camel@localhost.localdomain>	 <17006.64544.860436.620665@cse.unsw.edu.au>	 <4271DBB3.3090402@bio.ifi.lmu.de>	 <1114783702.10086.25.camel@lade.trondhjem.org>	 <427384DE.6050208@bio.ifi.lmu.de> <1114878578.14213.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Kris Vassallo <kris@linuxcertified.com>, nfs@lists.sourceforge.net,
	Olaf Kirch <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DSUM6-0000RK-Py
	for nfs@lists.sourceforge.net; Sun, 01 May 2005 23:24:34 -0700
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DSUM3-0002jz-5j
	for nfs@lists.sourceforge.net; Sun, 01 May 2005 23:24:34 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1114878578.14213.6.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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

Trond Myklebust wrote

> On lau , 2005-04-30 at 15:15 +0200, Frank Steiner wrote:
> 
>>reiserfs v3 on both servers (PC and pSeries).
> 
> Is the superblock in reiserfs 3.6 format? What
> does /proc/fs/reiserfs/<partition>/version say?

Hmm, there is not /proc/fs/reiserfs on my system (?), but

debugreiserfs  /dev/mapper/exportraid-home  (yes, LVM)

tells me:

Reiserfs super block in block 16 on 0xfc00 of format 3.6 with standard journal

So I guess that's ok. Also note that the problems wer introduced onlt
after the latest kernel update while the filesystem was created a year
ago and running stable since that time!

I'm currently testing the patch against the acess/getattr flooding that
you sent here because a colleague who is running a few computer pools
observes a correlation between high nfs load and the stale NFS handles.

cu,
Frank


-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
