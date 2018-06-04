Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailservice.tudelft.nl ([130.161.131.5]:40829 "EHLO
        mailservice.tudelft.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750723AbeFDP05 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 11:26:57 -0400
Subject: Re: RPC UDP message size limit
To: Chuck Lever <chucklever@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <726a7d92-bcb0-6120-252c-26d3a0951ddc@tudelft.nl>
 <4A3758CC-06B1-4F7D-B05E-5D9AA9E32C7C@gmail.com>
From: Robbert Eggermont <R.Eggermont@tudelft.nl>
Message-ID: <776808b0-82d2-18ae-8abb-471db6d6e02d@tudelft.nl>
Date: Mon, 4 Jun 2018 17:26:54 +0200
MIME-Version: 1.0
In-Reply-To: <4A3758CC-06B1-4F7D-B05E-5D9AA9E32C7C@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> 8KB seems to be a documented limit for UDP.

I tried to find documentation for this limit, but all I found was one 
reference to SunOS (of course), because of incompatible network hardware.

The real limit (based on the 16-bit length field defined in RFC 768, 
1980) is 65507 bytes (plus headers, for UDP over IPv4).

> However, using TCP would immediately work around the UDP message size
> limit. But perhaps the filer is not allowing a TCP connection for the
> MNT service?

TCP is not working for us at this moment (because of firewalling), so 
UDP is used as the fallback (as designed).

In our case, I'ld rather have the fallback fail because of a real 
hardware incompatibility than of an artificial software limit... ;-)

-- 
Robbert Eggermont
Intelligent Systems Support & Data Steward | TU Delft
+31 15 27 83234 | Building 28, Floor 5, Room W660
Available Mon, Wed-Fri
