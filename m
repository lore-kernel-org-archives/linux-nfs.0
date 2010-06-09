From: RaSca <rasca-9B074fXSGsOr88ip1nKoZ2D2FQJk+8+b@public.gmane.org>
Subject: Re: Problem using exportfs in an active-active nfs cluster
Date: Wed, 09 Jun 2010 10:01:39 +0200
Message-ID: <4C0F4A63.3070002@miamammausalinux.org>
References: <4C0E6ED0.60200@miamammausalinux.org> <20100609075425.7ec4ccd9@notabene.brown> <4C0F4634.8090102@miamammausalinux.org>
Reply-To: rasca-9B074fXSGsOr88ip1nKoZ2D2FQJk+8+b@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: rasca-9B074fXSGsOr88ip1nKoZ2D2FQJk+8+b@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from crash-1.cutaway.it ([89.186.66.80]:38683 "EHLO mail.cutaway.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755567Ab0FIIBl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 04:01:41 -0400
In-Reply-To: <4C0F4634.8090102-9B074fXSGsOr88ip1nKoZ2D2FQJk+8+b@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Il giorno Mer 09 Giu 2010 09:43:48 CET, RaSca ha scritto:
> Il giorno Mar 08 Giu 2010 23:54:25 CET, Neil Brown ha scritto:
> [...]
>> Try
>> exportfs -f
> Already tried, it didn't work. The file system is still locked by nfs=
d.

To be more specific: In my try first I do an exportfs -u of the export =
i=20
need to move and then i do an exportfs -f.
Client side the copy wait for a while and then gives some "Permission=20
denied" and exit.
Server side the problem, as already said is this one:

Jun  9 11:54:16 ubuntu-nodo1 lrmd: [692]: info: RA output:=20
(share-a-fs:stop:stderr) umount: /share-a: device is busy.#012=20
(In some cases useful info about processes that use#012         the=20
device is found by lsof(8) or fuser(1))
Jun  9 11:54:16 ubuntu-nodo1 lrmd: [692]: info: RA output:=20
(share-a-fs:stop:stderr)
Jun  9 11:54:16 ubuntu-nodo1 Filesystem[4065]: ERROR: Couldn't unmount=20
/share-a; trying cleanup with KILL
Jun  9 11:54:16 ubuntu-nodo1 Filesystem[4065]: INFO: No processes on=20
/share-a were signalled

As you can see the filesystem resource agent tries to unmount /share-a=20
but even if fuser or lsof does not give output, it still remains locked=
=20
(by nfsd, of course).

Have you got any other suggestion? Thanks a lot for your help.

--=20
RaSca
Mia Mamma Usa Linux: Niente =E8 impossibile da capire, se lo spieghi be=
ne!
rasca-9B074fXSGsOr88ip1nKoZ2D2FQJk+8+b@public.gmane.org
http://www.miamammausalinux.org
