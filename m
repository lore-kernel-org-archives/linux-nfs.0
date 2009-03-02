From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: redundant reverse DNS on NFS mount or umount
Date: Mon, 2 Mar 2009 12:41:55 -0500
Message-ID: <20090302174155.GF967@fieldses.org>
References: <499AD63B.20806@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: =?utf-8?Q?P=C3=A1draig?= Brady <P@draigBrady.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:37261 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752188AbZCBRl7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Mar 2009 12:41:59 -0500
In-Reply-To: <499AD63B.20806-V8g9lnOeT5ydJdNcDFJN0w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 17, 2009 at 03:22:35PM +0000, P=C3=A1draig Brady wrote:
> I've a problem where reverse DNS is being done by the NFS server.
> This is very problematic when the DNS server goes away.
> As far as I can see there should be no lookups being performed
> because I've nothing in /etc/hosts.{allow,deny} and just
> numeric hosts in /etc/exports.
>=20
> I can simulate this easily by putting a bad nameserver in /etc/resolv=
=2Econf
> and restarting the nfs server. Any mounts will take then take ages.
> Others seem to have had this issue as well, but possibly with
> non numeric names in /etc/exports:
> http://marc.info/?l=3Dlinux-nfs&m=3D110977757630297&w=3D2
> http://marc.info/?l=3Dlinux-nfs&m=3D111015343008456&w=3D2
>=20
> Here are my config details:
>=20
> # rpm -q nfs-utils
> nfs-utils-1.1.0-6.fc8
>=20
> # cat /etc/resolv.conf
> search company.com
> nameserver 192.168.2.110
>=20
> # cat /etc/exports
> /home   192.168.2.25(async,rw,all_squash,anonuid=3D500,anongid=3D500)
>=20
> Any ideas appreciated.

I agree that DNS lookups shouldn't be required in this case.

It's rpc.mountd that's responsible for this, so if you can figure out
where in the mountd code this is happening, it shouldn't be hard to fix=
=2E

--b.
