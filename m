Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:41054 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758539Ab0EYVCF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 17:02:05 -0400
Received: by gwaa12 with SMTP id a12so185519gwa.19
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 14:02:04 -0700 (PDT)
In-Reply-To: <20100525203742.GL7085@fieldses.org>
References: <4BFBCF77.2070702@dgreaves.com>
	 <20100525203742.GL7085@fieldses.org>
Date: Tue, 25 May 2010 17:02:03 -0400
Message-ID: <AANLkTin633rOUeUrCRdEaWC_bBpZnlR9TJMTUUy_lSzg@mail.gmail.com>
Subject: Re: NFS wiki : NFSv4 Enduser doc kerberos
From: Kevin Coffman <kwc@citi.umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: David Greaves <david@dgreaves.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, May 25, 2010 at 4:37 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Tue, May 25, 2010 at 02:24:07PM +0100, David Greaves wrote:
> > FYI I've made an attempt to update this page:
> >   http://wiki.linux-nfs.org/wiki/index.php/Enduser_doc_kerberos
> >
> > If someone could please take a look and correct any errors I've made that
> > would be nice.
> >
> > Some questions:
> > * should a client have an nfs/<fqdn> principal  (it works without)
>
> I'm actually not sure what the latest client requires--I thought it
> still needed some kind of machine credential on the client.

Kerberos mounts can be done w/o a machine credential, but root (or the
user doing the mount) must obtain credentials somehow.  To be
workable, I would think that a keytab of some kind is required (with a
cron using it to keep credentials fresh).

> > * Is the "allow_weak_crypto=true" part still correct?
>
> Yes, unless you're running the very latest (unreleased) upstream kernel
> and nfs-utils, which includes support for stronger crypto.
>
> --b.
> --
