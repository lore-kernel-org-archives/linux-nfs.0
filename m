From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: NFS re-export of non-local mountpoint
Date: Mon, 2 Jan 2006 19:57:46 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0601021956490.29084@maggie.lkpg.cendio.se>
References: <OF9EFE8519.B9EB421D-ONC12570EA.004FBF22-C12570EA.00519D78@de.ibm.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-2054831717-1136228266=:29084"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EtUsY-0008Kd-A0
	for nfs@lists.sourceforge.net; Mon, 02 Jan 2006 10:57:58 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EtUsX-0008RX-5G
	for nfs@lists.sourceforge.net; Mon, 02 Jan 2006 10:57:58 -0800
To: Holger Smolinski <smolinski@de.ibm.com>
In-Reply-To: <OF9EFE8519.B9EB421D-ONC12570EA.004FBF22-C12570EA.00519D78@de.ibm.com>
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

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-2054831717-1136228266=:29084
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

On Mon, 2 Jan 2006, Holger Smolinski wrote:

> We are looking for a solution, that will allow us to re-export a=20
> non-local mountpoint (e.g. Samba Share, or NFSmount) through at least=20
> NFSv3 to another system using a Linux NFS Server. Sinde knfsd lacks thi=
s=20
> functionality and we are not aware of any currently maintained user=20
> space Linux NFS Server, that has this capability, we are currently=20
> assessing the effort to add this functions to the knfsd. So far

I think UNFS3 is what you are looking for: http://unfs3.sourceforge.net/

Regards,
--=20
Peter =C5strand		ThinLinc Chief Developer
Cendio			www.cendio.se
Teknikringen 3
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-2054831717-1136228266=:29084--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
