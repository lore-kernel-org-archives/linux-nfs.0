From: "Donald Tournier" <d.tournier@ich.ucl.ac.uk>
Subject: Re: exporting directory containing multiple mounted
     partitions
Date: Thu, 8 Jul 2004 14:33:54 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <2479.194.82.240.48.1089293634.squirrel@194.82.240.48>
References: <4298.194.82.240.48.1089291432.squirrel@194.82.240.48>
Reply-To: d.tournier@ich.ucl.ac.uk
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BiZ2M-0002Bq-Hf
	for nfs@lists.sourceforge.net; Thu, 08 Jul 2004 06:34:06 -0700
Received: from curie.ich.ucl.ac.uk ([194.82.240.247] helo=franklin.ich.ucl.ac.uk)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BiZ2L-0008Po-Fm
	for nfs@lists.sourceforge.net; Thu, 08 Jul 2004 06:34:06 -0700
In-Reply-To: <4298.194.82.240.48.1089291432.squirrel@194.82.240.48>
To: nfs@lists.sourceforge.net
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

Hello again,

Sorry, I was being dense. I've finally spotted the 'nohide' option on the
exports man page, and realised that it did in fact answer my question...
Guess I'll just have to export everything separately then.

Thanks,

Donald.

Donald Tournier said:
> Hi,
>
> I am trying to export a directory via NFS, within which I have already
> mounted the data partitions from the local hard drives. The idea is to
> mount all the data partitions into one directory (/home/hostname/[a-z]),
> and then to export the whole lot (/home/hostname) in one go. I find that
> although the mount operation seems to work, the directories corresponding
> to the individual partitions appear empty.
>
> For example, if I do:
> # ls /home/hostname
> I get:
> a/  b/  c/  d/
> corresponding to the 4 data partitions on that host. But each of these
> directory appears utterly empty on any remote host.
>
> I'm assuming that this is a limitation/feature of NFS. Is this correct,
> and is there any way to get around it? Do I have to go back to exporting
> each data partition separately?
>
> Thanks for any hints.
>
> Donald.
>
> PS: using SuSE 8.2 & 9.1
>
>
>
>
> -------------------------------------------------------
> This SF.Net email sponsored by Black Hat Briefings & Training.
> Attend Black Hat Briefings & Training, Las Vegas July 24-29 -
> digital self defense, top technical experts, no vendor pitches,
> unmatched networking opportunities. Visit www.blackhat.com
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>




-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
