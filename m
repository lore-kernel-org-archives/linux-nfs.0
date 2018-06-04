Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35992 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751085AbeFDPtT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 11:49:19 -0400
Received: by mail-io0-f169.google.com with SMTP id d73-v6so38602284iog.3
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 08:49:19 -0700 (PDT)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: RPC UDP message size limit
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <776808b0-82d2-18ae-8abb-471db6d6e02d@tudelft.nl>
Date: Mon, 4 Jun 2018 11:49:16 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <347E80FE-C62C-4724-9187-650EEBBE6AE0@gmail.com>
References: <726a7d92-bcb0-6120-252c-26d3a0951ddc@tudelft.nl>
 <4A3758CC-06B1-4F7D-B05E-5D9AA9E32C7C@gmail.com>
 <776808b0-82d2-18ae-8abb-471db6d6e02d@tudelft.nl>
To: Robbert Eggermont <R.Eggermont@tudelft.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jun 4, 2018, at 11:26 AM, Robbert Eggermont =
<R.Eggermont@tudelft.nl> wrote:
>=20
>> 8KB seems to be a documented limit for UDP.
>=20
> I tried to find documentation for this limit, but all I found was one =
reference to SunOS (of course), because of incompatible network =
hardware.

The text I quoted you is from the Linux man page for clnt_create(3).


> The real limit (based on the 16-bit length field defined in RFC 768, =
1980) is 65507 bytes (plus headers, for UDP over IPv4).

That's the architectural limit. There's also a practical limit
that is much lower.

UDP datagrams have to be re-assembled from smaller frames. The IP
layer does that using a 16-bit ID header field and verifies the
re-assembly with a weak checksum. It's pretty easy to fool the
checksum by assembling the frames out of order, which can happen
if the ID header value wraps.

There are other problems that make UDP problematic for any RPC
program that relies on the datagram to contain the correct data
in the correct order.

To mitigate these problems, the maximum size of UDP frames is
reduced. IMO 8KB + a handful is about as large as we ever want to
go in the general case.


>> However, using TCP would immediately work around the UDP message size
>> limit. But perhaps the filer is not allowing a TCP connection for the
>> MNT service?
>=20
> TCP is not working for us at this moment (because of firewalling), so =
UDP is used as the fallback (as designed).
>=20
> In our case, I'ld rather have the fallback fail because of a real =
hardware incompatibility than of an artificial software limit... ;-)

Making a library change that impacts all RPC consumers is IMO
quite inappropriate, for the reason explained above. The
preferred way to address this is to increase the UDP message
size limit only for showmount.


>> IIUC showmount could use the clnt_{vc,dg}_create(3) APIs instead of
>> the generic clnt_create(3) API to specify a larger message size =
limit.


Can you try this suggestion and let us know if it's effective?


--
Chuck Lever
chucklever@gmail.com



