Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.22]:41618 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752326Ab2LEQYA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Dec 2012 11:24:00 -0500
Message-ID: <50BF751C.90808@gmx.de>
Date: Wed, 05 Dec 2012 17:23:56 +0100
From: Florian Manschwetus <florianmanschwetus@gmx.de>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs4 acl problems using Nexenta-Communityedition Server and debian
 testing clients
References: <50BF1854.1020204@gmx.de> <4FA345DA4F4AE44899BD2B03EEEC2FA90B337973@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90B337973@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am 05.12.2012 16:41, schrieb Myklebust, Trond:
> On Wed, 2012-12-05 at 10:48 +0100, Florian Manschwetus wrote:
>> I setup a little network using a central storage server based on
>> nexenta-Communityedition clients use homes and several shares via nfs4.
>> As we have some shares used for webdevelopment purposes it is desired to
>> have acls inherited for specific groups access and user access
>
> Inherited acls are inherently incompatible with basic POSIX
> open(O_CREAT). The latter takes a mode bit argument that will clobber
> your inherited acl.
>
>> (webserver user). I also have trouble with sticky-bit inheritance, which
>> is needed as the linux gui tools unaware of nfs-acls. Are there plans to
>> improve support for nfs acls?
>>
>> Maybe someone here have successfully a solaris nfs server running with
>> linux clients using extended acls, with inheritance working as expected?
>>
>> It is really annoying having users not allowed to view/edit files/dirs
>> they copied just the moment.
>
> This is not the right list for requesting gui tool changes. The right
> address would be the GNOME, KDE and XFCE project mail lists.
>
Sounds reasonable, but at least a cp -r /share/orig /share/copy should 
produce a copy with expected acls (as defined on /share).

My normal outcoming is that the user coping the directory is unallowed 
to access it, by @owner-deny ace. Which is really ugly. Unfortunately I 
can't find a mode making the server to enforce correct inheritance 
(disallowing the users to alter acls, mode, etc via nfs, maybe with 
nfs-acls tools but this isn't really needed).

Regards,
Florian
