From: Piotr Oniszczuk <piotr.oniszczuk-upgw/6zDzsc@public.gmane.org>
Subject: [NFS] Best solution for following problem...
Date: Sat, 31 Oct 2009 19:45:28 +0100
Message-ID: <4AEC85C8.4030405@aster.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060909050208080306020700"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:56018 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933162AbZJaT2F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 31 Oct 2009 15:28:05 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1N4JcN-00014T-Gx
	for linux-nfs@vger.kernel.org; Sun, 01 Nov 2009 06:28:07 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060909050208080306020700
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit

Hi *

I'm looking for advice for best solution for following problem:

I have file server sharing files to diskless clients via NFS

I want  have setup, where pluging ext. USB HDD will be dynamically 
visible on clients as new <subdir> with HDD contents.
So if user plug USB HD on server, diskless clients should see plugged 
HDD contents in dynamically created <subdirectory> with name equal to HD 
label and HD contents inside it.

I already wrote udev script which auto creates subdir=<label> in NFS 
server shared dir, and automounts USB HD in this subdir.

Issue is that diskless clients don't see this subdir  unless  I issue on 
server

exportfs -ua
exportfs -a

Problem is that  above unexporting/exporting sequence issued on server 
brokes existing NFS shares between clients and server.

What is most elegant solution for such functional requirement ?

thx in advance




 


--------------060909050208080306020700
Content-Type: text/x-vcard; charset=utf-8;
 name="piotr_oniszczuk.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="piotr_oniszczuk.vcf"

begin:vcard
fn:Piotr Oniszczuk
n:Oniszczuk;Piotr
adr:;;KEN 49 m241;Warszawa;;02-797;Polska
email;internet:piotr.oniszczuk-upgw/6zDzsc@public.gmane.org
tel;work:+48 22 515 52 75
tel;home:+48 22 489 68 62
tel;cell:+48 508 047 160
version:2.1
end:vcard


--------------060909050208080306020700
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
--------------060909050208080306020700
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--------------060909050208080306020700--


