From: xing jing <xingjing-3pZTqkFmMFknDS1+zs4M5A@public.gmane.org>
Subject: how to parse the 64byte NFSv3 file handle
Date: Mon, 19 May 2008 16:14:52 +0800
Message-ID: <483136FC.4050208@ncic.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gatekeeper.ncic.ac.cn ([159.226.41.188]:62832 "HELO ac.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755516AbYESIZi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2008 04:25:38 -0400
Received: from [10.10.11.253] (unknown [159.226.41.129])
	(Authenticated sender: xingjing)
	by ncic.ac.cn (Postfix) with ESMTP id B9C92136855
	for <linux-nfs@vger.kernel.org>; Mon, 19 May 2008 16:07:36 +0800 (CST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi,all
recently, I want to get some information (like file access patten)
from a trace of NFS client. The simplest way may be parse the file
handle to get the file ino and directory ino, but I don't know how to
get them from the 64 of 16 hexadecimal. Can you tell me how to parse
file handle to get useful information, thanks very much.

best regards=A3=A1

Jing


PS, there is some file handles from the trace

bcdaa400ce7a23012000000000a4dabcce7a230164860000a0cf90002e303000
b7905500246c6a1220000000000cec5413b72e3264860000a0cf90002e303000
bcdaa400ce7a23012000000000a4dabcce7a230164860000a0cf90002e303000
bcdaa400ce7a230120000000004ad8e8f8b2230164860000a0cf90002e303000
bcdaa400ce7a230120000000004ad8e8f8b2230164860000a0cf90002e303000
bcdaa400ce7a230120000000001074cd975e480564860000a0cf90002e303000
