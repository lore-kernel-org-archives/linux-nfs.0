From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: ixgbe_clean_tx_irq: tx hang 1 detected, resetting adapter
	(2.6.32.8)
Date: Wed, 17 Feb 2010 19:07:50 -0800
Message-ID: <86802c441002171907m2fc28ccay4dc67ce3c66693e5@mail.gmail.com>
References: <4B7824F1.6000202@krogh.cc>
	 <4807377b1002171453n277cfea3s6d7f3629bd43f674@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f187.google.com ([209.85.222.187]:57335 "EHLO
	mail-pz0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752714Ab0BRDHw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Feb 2010 22:07:52 -0500
In-Reply-To: <4807377b1002171453n277cfea3s6d7f3629bd43f674-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 17, 2010 at 2:53 PM, Jesse Brandeburg
<jesse.brandeburg@gmail.com> wrote:

> Wow, thats a monster machine, 8 nodes, 128GB ram. =A0Can we get a ful=
l
> lspci -vvv output, as well as ethtool -e eth7 and eth8

SUN    X4600 M2

it could support 512g ram.

Yinghai
