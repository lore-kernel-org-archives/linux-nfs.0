Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:50035 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403Ab3GQUzH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jul 2013 16:55:07 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: Error writing to nfs4 with 3.11-rc1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHsu+b9vWUyCGHSs==Na=VntwvYp65=rva7+y9aQDXquxX4t-A@mail.gmail.com>
Date: Wed, 17 Jul 2013 16:54:59 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <F3EFA483-0662-4226-AAF3-DCF12D48485E@oracle.com>
References: <CAHsu+b_hhSr2vwcwM8TX3=xF=3HffUXG=YLVLcsEpH1wHn+JoA@mail.gmail.com> <A5C56FD6-9E14-43A3-8627-1C8F77EC6926@oracle.com> <CAHsu+b9vWUyCGHSs==Na=VntwvYp65=rva7+y9aQDXquxX4t-A@mail.gmail.com>
To: Andre Heider <a.heider@gmail.com>, Rick Macklem <rmacklem@uoguelph.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 17, 2013, at 3:35 PM, Andre Heider <a.heider@gmail.com> wrote:

> On Wed, Jul 17, 2013 at 9:10 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> On Jul 17, 2013, at 2:55 PM, Andre Heider <a.heider@gmail.com> wrote:
>> 
>>> Hi,
>>> 
>>> I'm having problems using 3.11-rc1 as nfs4 client (with a FreeBSD 9.1
>>> server) using sec=sys.
>>> 
>>> With the same server+client setup, just booting different kernels:
>>> 3.9.10 works without issues
>>> 3.10.1 works too, but introduced "RPC: AUTH_GSS upcall timed out." in
>>> dmesg (iirc I don't need gss with sec=sys)
>> 
>> Not a requirement, but running gssd should make that message go away.  The client is attempting to use krb5i to manage its lease on the server, and falling back to AUTH_UNIX when it sees gssd is not running.
>> 
>>> 3.11-rc1 reading from the server still works, writing fails
>>> 
>>> Even a simple touch on the share fails with:
>>> touch: cannot touch ‘/mnt/andre/test’: Input/output error
>> 
>> A network capture is a reasonable place to start.
>> 
>>  # tcpdump -s0 -w /tmp/raw
>> 
>> Then try your touch test again.  Stop the tcpdump.  You can post a compressed version of the raw dump here if it's short.
> 
> Attached two dumps, one from 3.10 (works) and one from 3.11 (doesn't work).

Commit a09df2ca "NFSv4: Extend fattr bitmaps to support all 3 words", introduced in 3.11-rc1, changes the Linux OPEN operation to send a 3-word bitmask for the fattr4 data type.  This was done to support NFSv4 minor version 2, which adds bits in the 3rd word.

Apparently FreeBSD servers support only 2-word fattr4 bitmasks...?

RFC 3530 defines the bitmask4 type as a variable length array of uint32_t.  The minor versioning rules in 3530bis Chapter 11 say:

	•  Minor versions may append attributes to the bitmap4 that
           represents sets of attributes and to the fattr4 that
           represents sets of attribute values.

I don't see any other limit placed on the size of the fattr4's bitmask array in RFC 3530, other than the number of bits that are defined for fattr4.  But I didn't look carefully.

By the way, the NFSv4 OPEN request parsing in Wireshark 1.10.0 is totally screwed up.  Has anyone reported this to the Wireshark community?  Wireshark 1.8.8 appears to parse OPEN requests correctly, and is able to handle the 3-word bitmask correctly.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




