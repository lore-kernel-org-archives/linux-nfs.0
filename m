Return-Path: linux-nfs-owner@vger.kernel.org
Received: from exo1066.net2.nerim.net ([213.41.175.60]:63503 "EHLO
	mx1.exosec.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754384Ab2AQPoA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 10:44:00 -0500
Date: Tue, 17 Jan 2012 16:43:19 +0100
From: Bertrand Jacquin <bjacquin@exosec.fr>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: I/O Wait on exportfs
Message-ID: <20120117154319.GB19990@lady-voodoo.exosec.local>
References: <20120117142945.GA19990@lady-voodoo.exosec.local>
 <20120117150901.GA12274@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20120117150901.GA12274@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le mardi 17 janvier 2012 à 16h09, « J. Bruce Fields » a écrit :
> On Tue, Jan 17, 2012 at 03:29:45PM +0100, Bertrand Jacquin wrote:
> > For a specific case I have /etc/exports with 1281 entries as I need
> > mount --bind to be exported to NFS Clients too.
> 
> Could you explain what you mean by that?

In this case, I need /srv/mail to be exported to clients. But for a 1
month period, I need folders present in /srv/mail2 to be accessible in
/srv/mail.

We are moving datas to a SAN, and to avoid modifying any mail configuration
(and the long list depending on it), I mount /srv/mail2 subdirectory to
/srv/mailsubdirectory until all subdirectory are migrated :

 # mount /dev/drbd5 /srv/mail
 # mount /dev/mapper/iqn.dXX:san1.target0-lun0 /srv/mail2
 # <moving data from /srv/mail/user1 to /srv/mail2/user1>
 # mount --bind /srv/mail2/user1 /srv/mail/user1

To make /srv/mail2/user1 data visible for NFS client, I need to use
crossmnt options in /etc/exports as nohide is client per client.

exports(5) say :

  Thus when a child filesystem "B" is mounted on a parent "A", setting
	crossmnt on "A" has the same effect as setting "nohide" on B.

But I can't say that this had work at all, but adding child filesystem
in /etc/export, then 'mount -o remount' NFS partition on client fix
that. I'm maybe wrong, but my tests put me in that way.

> > Since I have ~1100 entries, reexporting /etc/exports have some bad
> > effects to connected clients, load rise to ~500 for 4/5 minutes, this is
> > always reproducible.
> > 
> > This was using 'exportfs -ra'. I did try with 'exportfs
> > 192.168.0.1:/srv/mail/1234' to avoid reexport every directories, and
> > the sync process but the result is the same.
> 
> Does a -t option (see rpc.mountd(8)) help?

This is interesting

Bertrand

-- 
Bertrand Jacquin, EXOSEC (http://www.exosec.fr/)
ZAC des Metz - 3 Rue du petit robinson - 78350 JOUY EN JOSAS
Tel: +33 1 30 67 60 65  -  Fax: +33 1 75 43 40 70
GSM: +33 6 71 01 70 30  -  mailto:bjacquin@exosec.fr
