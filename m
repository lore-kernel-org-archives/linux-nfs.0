From: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
Subject: Re: on demaind nfs
Date: Mon, 19 Jul 2010 10:52:07 +0200
Message-ID: <1279529527.13175.0.camel@thorin>
References: <AANLkTinokaOEBVHu5KMxofnnkN-0e5MsIfnf1zNPhVmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Peng Yu <pengyu.ut@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from esgaroth.petrovitsch.at ([78.47.184.11]:6209 "EHLO
	esgaroth.petrovitsch.priv.at" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760216Ab0GSIwN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Jul 2010 04:52:13 -0400
In-Reply-To: <AANLkTinokaOEBVHu5KMxofnnkN-0e5MsIfnf1zNPhVmA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

On Son, 2010-07-18 at 19:31 -0500, Peng Yu wrote:
[...]
> I've seen that an nfs filesystem can be mount on demand. Suppose, that
> the nfs filesystems should be mounted on /local, say /local/nfs1 ...
> /local/nfs10. If I don't access them for a while, then I will not see
> them mounted (no such file system in df).
> 
> If I try to cd to /local/nfs1, then I will see it in df. I'm wondering
> if any body can let me know how to mount nfs file system on demand.

Google for "autofs" and "automount".

	Bernd
-- 
Bernd Petrovitsch                  Email : bernd@petrovitsch.priv.at
                     LUGA : http://www.luga.at

