From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: Re: cache/mmap()/server coherency problems
Date: Tue, 14 Jan 2003 10:27:10 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B9160C77D9@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail2.conoco.com ([12.31.208.227])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YTuT-0007ow-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 08:27:29 -0800
To: <nfs@lists.sourceforge.net>
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



> Message: 5
> Date: Mon, 13 Jan 2003 20:56:55 -0800 (PST)
> To: nfs@lists.sourceforge.net
> From: Chris Caputo <ccaputo@alt.net>
> Subject: [NFS] cache/mmap()/server coherency problems
>=20
> On 2.4.18 and 2.4.20 I am seeing the following problem:
>=20
>  1) client A process C opens and mmaps (PROT_READ, MAP_SHARED) a file =
on
>     an NFS server.  It keeps it mapped for the duration of the =
following
>     steps.
>=20
>  2) client B process D opens, adds data to the end of the same file, =
and=20
>     then closes it.
>=20
>  3) client B process E runs md5sum on the file.
>=20
>  4) client A process F runs md5sum on the file too.  But the result is =

>     different than the result of the md5sum in step 3.
>=20
> Under kernel 2.2.21 this problem did not happen.
>=20
	I am pretty sure we had more or less exactly what you described happen
	on 2.2.19 so I may have just been luck.

	Our process that someone saw was:
		client a writes odd records.
		client b writes even records
		and if client a or b tries to verify the file immediately after it =
finishes,
	      then it gets all 0x00 for what the other client wrote until a =
cache flush
		is forced.  The method that we use for force a cache flush is to wait
		a second or two and then run a rsh to the server doing a touch on=20
	      the file in question.    If client b is the verifier and he =
finished first
		by more than a second, then every thing would be ok since the date
		on the file was already not what client b expected (had in its =
metadata
		cache)-so it forces a cache flush, but if client b finishes last or=20
	      the same as client a the process will fail since client b sees =
the=20
		date/time that it expects and does not expect that the file
		has been changed since in last touched it.

		I believe in a later version the date/time stamp accuracy is
		supposed to be changed to have a much higher resolution
		making this problem harder to duplicate (currently it has a
		1 second resolution).

				Roger=20

> An analysis of the file from client A shows that there are zeros in =
the
> file (where there should be new text) between where process C =
originally
> opened and mmaped the file and the end of a page boundary, ala:
>=20
>   00aa3d0 3838 3631 0934 4341 5346 333a 312f 312f
>   00aa3e0 3437 3737 6635 3162 6433 3d32 3639 2f36
>   00aa3f0 0a31 0000 0000 0000 0000 0000 0000 0000
>   00aa400 0000 0000 0000 0000 0000 0000 0000 0000
>   *
>   00ab000 6134 2e78 6f63 3e6d 3c09 3631 7473 7631
>   00ab010 3438 3776 6371 3870 6462 6a76 3066 686c
>   00ab020 7061 3034 6738 6d37 3033 6661 3440 7861
>   00ab030 632e 6d6f 203e 303c 6264 3132 3834 6465
>=20
> Now, if the mmap from step 1 is munmaped and the file is closed the =
file
> will still be corrupted.  I assume this is because the file is still =
in
> the file cache and it is not accurate there too.  Once it has been =
purged
> from the file cache, when I then run md5sum, the checksum is correct.
>=20
> Is this expected behavior?
>=20
> I was thinking that when the file is opened, the lookup NFS call will
> result in new file size info being shared with the VFS, and the VFS =
would
> know that the data in any page cached, beyond its previously known =
file
> length, is invalid and that the whole page would need to be reloaded =
next
> time the file is accessed.  This all seems to happen, except when =
someone
> has mmaped the file...
>=20
> Chris
>=20
>=20
>=20


-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
