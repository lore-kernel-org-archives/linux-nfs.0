Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod6og103.obsmtp.com ([64.18.1.185]:36803 "HELO
	exprod6og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754150Ab0IAJrL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Sep 2010 05:47:11 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: NFS version4 maximum on-the-wire data size.
Date: Wed, 1 Sep 2010 05:39:59 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90CFB48D0@nsmail.netscout.com>
From: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
To: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I am unable to get the exact count for the amount of on-the-wire data
size that NFSv4 supports. 

I could get exact figures in case of NFSv3 (http://nfs.sourceforge.net).
It's 60KB when NFSv3 is used over UDP and implementation dependent in
case it is used over TCP. Any idea about NFSv4 statistics? 

Any pointers would be appreciated.

[Please CC me in the email, as I am not subscribed to the list].

--
Thanks,
Nilesh
