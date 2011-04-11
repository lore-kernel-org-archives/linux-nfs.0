Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:44770 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406Ab1DKN5i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2011 09:57:38 -0400
In-Reply-To: <20110411133602.GA5321@hallyn.com>
References: <4D9431B3.2070305@parallels.com>
	<20110405034641.GC6764@hallyn.com>
	<4D9F24F2.9020603@parallels.com>
	<4DA30222.5040902@parallels.com>
	<20110411133602.GA5321@hallyn.com>
Date: Mon, 11 Apr 2011 16:57:37 +0300
Message-ID: <BANLkTi=sh1CB+e1EhU-c-Bs3BCszWEBTMA@mail.gmail.com>
Subject: Re: [PATCH 3/3] Compare namespaces when comparing addresses in
 auth_unix cache.
From: Alexey Dobriyan <adobriyan@gmail.com>
To: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Rob Landley <rlandley@parallels.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, containers@lists.linux-foundation.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Tim Spriggs <tims@uahirise.org>, Kir Kolyshkin <kir@parallels.com>,
        Pavel Emelyanov <xemul@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Apr 11, 2011 at 4:36 PM, Serge E. Hallyn <serge@hallyn.com> wrote:

> Besides use-after-free, the other concern is an invalid net_eq()
> result due to the * being re-used for a new netns.

Exactly.

"struct net" dies last, no exceptions, anything different is a disaster.
