From: Andy Adamson <andros@netapp.com>
Subject: Re: Device or resource busy
Date: Wed, 29 Oct 2008 11:58:52 -0400
Message-ID: <1225295932.10717.11.camel@localhost.localdomain>
References: <20081027131034.GC25001@speutel.de>
	 <1225116112.7842.3.camel@heimdal.trondhjem.org>
	 <20081027142944.GD25001@speutel.de>
	 <1225119712.14242.10.camel@heimdal.trondhjem.org>
	 <20081029150927.GE13990@speutel.de>
Reply-To: andros@netapp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Stephan =?ISO-8859-1?Q?Windm=FCller?=
	<stephan.windmueller-ogaGWlaKng3jEoi5djuKH7NAH6kLmebB@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5055 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752083AbYJ2QAD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Oct 2008 12:00:03 -0400
In-Reply-To: <20081029150927.GE13990-YXCdMCmAy7qELgA04lAiVw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

On Wed, 2008-10-29 at 16:09 +0100, Stephan Windm=C3=BCller wrote:
> On Mon, 27. Oct 2008, Trond Myklebust wrote:
>=20
> > As I said earlier, every time you cross from one volume to another =
(even
> > if it is on the same server), a mountpoint is automatically created=
=2E
>=20
> How do I "cross from one volume to another"?=20

When a user traverses the NFS namespace on the client, and crosses from
one server volume to another (fsid change) the NFS client software
automagically does a mount. This is required to avoid inode number
collisions.

> Is there something I can
> test to reproduce this behaviour? It seems that not all users have th=
is
> problem.

That's because all users don't traverse the file system in the same way=
=2E

>=20
> On the server I shared every single home directory instead of
> /export/home. Could this be the cause of the problem?
>=20
> - Stephan
