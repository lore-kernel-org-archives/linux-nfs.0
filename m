From: Herbert Engelmann <Herbert.Engelmann@lrz-muenchen.de>
Subject: Re: lockd/statd: failed to create /var/lib/nfs/sm/<hostname>
Date: Thu, 5 Jan 2006 22:59:47 +0100
Message-ID: <200601052300.05470.engelmann@lrz.de>
References: <200601051456.20478.engelmann@lrz.de> <20060105145405.GM25157@suse.de>
Reply-To: Herbert.Engelmann@lrz-muenchen.de
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net, Helge.Hansemann@lrz-muenchen.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EudA4-00032G-FP
	for nfs@lists.sourceforge.net; Thu, 05 Jan 2006 14:00:44 -0800
Received: from mailrelay1.lrz-muenchen.de ([129.187.254.106])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EudA2-00006n-1C
	for nfs@lists.sourceforge.net; Thu, 05 Jan 2006 14:00:44 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20060105145405.GM25157@suse.de>
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

=2D----BEGIN PGP SIGNED MESSAGE-----

Am Donnerstag, 5. Januar 2006 15:54 schrieb Olaf Kirch:
> On Thu, Jan 05, 2006 at 02:56:18PM +0100, Herbert Engelmann wrote:
> > Jan  5 10:58:10 xxxxxx kernel: lockd/statd: failed to create
> > /var/lib/nfs/sm/<full qualified hostname>: err=3D-2
> >
> > Jan  5 10:58:10 xxxxxx kernel: lockd: failed to monitor <full qualified
> > hostname>
>
> That seems to be a Suse kernel you're running. Which kernel is that?
> Are you running the most recent update kernel?
>

That's right. SuSE 9.3 with Kernel
2.6.11.4-21.10-smp #1 SMP Tue Nov 29 14:32:49 UTC 2005.

I do not know if there is a more recent kernel.

regards

Herbert Engelmann
=2D --=20
H. Engelmann, 089-289-28836, engelmann@lrz.de
PGP-Key : http://www.lrz-muenchen.de/~engelmann/info/pgp.em.html

=2D----BEGIN PGP SIGNATURE-----
Version: 2.6.3in
Charset: noconv

iQCVAwUBQ72W26hxGsmXUG+lAQHIRAQAj7+8WMOmSw/7LsQKFddvDuGaF5hJYcb0
CECNHbZhWoLFthhT2Fh9zhVj/zGCZSj0ix95lEuwmWnOCYSPb5dfOUB6D5P5QVjf
8Fc3ydRSNAYutuxXQz0lDYKm9HRINQlzM+KXcjdcevgcBRupqbmqOpJ24MaGB3OL
=460y+dVsYdmA=3D
=3DraUl
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
