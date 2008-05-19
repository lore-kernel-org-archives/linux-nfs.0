From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: how to parse the 64byte NFSv3 file handle
Date: Mon, 19 May 2008 11:56:36 +0300
Message-ID: <483140C4.3010104@panasas.com>
References: <483136FC.4050208@ncic.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Cc: linux-nfs@vger.kernel.org
To: xing jing <xingjing-3pZTqkFmMFknDS1+zs4M5A@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:21224 "EHLO
	cassoulet.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751417AbYESI46 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2008 04:56:58 -0400
In-Reply-To: <483136FC.4050208-3pZTqkFmMFknDS1+zs4M5A@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 19, 2008, 11:14 +0300, xing jing <xingjing-3pZTqkFmMFknDS1+zs4M5A@public.gmane.org> wrote:
> hi,all
> recently, I want to get some information (like file access patten)
> from a trace of NFS client. The simplest way may be parse the file
> handle to get the file ino and directory ino, but I don't know how to
> get them from the 64 of 16 hexadecimal. Can you tell me how to parse
> file handle to get useful information, thanks very much.
>=20
> best regards=A3=A1
>=20
> Jing
>=20
>=20
> PS, there is some file handles from the trace
>=20
> bcdaa400ce7a23012000000000a4dabcce7a230164860000a0cf90002e303000
> b7905500246c6a1220000000000cec5413b72e3264860000a0cf90002e303000
> bcdaa400ce7a23012000000000a4dabcce7a230164860000a0cf90002e303000
> bcdaa400ce7a230120000000004ad8e8f8b2230164860000a0cf90002e303000
> bcdaa400ce7a230120000000004ad8e8f8b2230164860000a0cf90002e303000
> bcdaa400ce7a230120000000001074cd975e480564860000a0cf90002e303000

What server generated them?
This doesn't look like the linux nfsd format (as defined in
include/linux/nfsd/nfsfh.h)

That file handle contents are opaque to the client so you'd
need to have the server's code or reverse engineer its
structure.

Try running ls -li on a file and parent directory and see if
you can identify the respective inode numbers in the filehandle.
(likely to be coded in big-endian)

Benny

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

