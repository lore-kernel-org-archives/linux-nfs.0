Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:28280 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759864Ab3GSQdZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jul 2013 12:33:25 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: Error writing to nfs4 with 3.11-rc1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130719161313.GA20026@fieldses.org>
Date: Fri, 19 Jul 2013 12:33:11 -0400
Cc: Andre Heider <a.heider@gmail.com>, Rick Macklem <rmacklem@uoguelph.ca>,
        linux-nfs@vger.kernel.org
Message-Id: <85DF5611-5C53-4B65-AA05-8436C9F00680@oracle.com>
References: <CAHsu+b_hhSr2vwcwM8TX3=xF=3HffUXG=YLVLcsEpH1wHn+JoA@mail.gmail.com> <A5C56FD6-9E14-43A3-8627-1C8F77EC6926@oracle.com> <CAHsu+b9vWUyCGHSs==Na=VntwvYp65=rva7+y9aQDXquxX4t-A@mail.gmail.com> <F3EFA483-0662-4226-AAF3-DCF12D48485E@oracle.com> <20130719161313.GA20026@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 19, 2013, at 12:13 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Jul 17, 2013 at 04:54:59PM -0400, Chuck Lever wrote:
>> By the way, the NFSv4 OPEN request parsing in Wireshark 1.10.0 is totally screwed up.  Has anyone reported this to the Wireshark community?  Wireshark 1.8.8 appears to parse OPEN requests correctly, and is able to handle the 3-word bitmask correctly.
> 
> What exactly is screwed up?

For example, if you undisclose all of the parsed elements of an OPEN reply, the parsing of the XDR is wrong and the following replies in the compound become unparsable "data".

I've reproduced this for every installation of 1.10.0, Linux and Mac OS, that I've done.

I'm looking at a trace where the client sends an unchecked create OPEN via this compound:

PUTFH, OPEN, GETFH, ACCESS, GETATTR

And here is the reply, as parsed by Wireshark.  The replies after the OPEN are rendered as 216 bytes of unparsed "data".  The Delegation Type is 2950154659.  fattr4_mode looks wrong as well, the requested mode was 644.

Close examination of the actual bytes in this reply shows that the reply sent by the server was correct XDR and a plausible result, and the client continues normal and correct operation.

Network File System, Ops(5): PUTFH OPEN
    [Program Version: 4]
    [V4 Procedure: COMPOUND (1)]
    Status: NFS4_OK (0)
    Tag: <EMPTY>
        length: 0
        contents: <EMPTY>
    Operations (count: 5)
        Opcode: PUTFH (22)
            Status: NFS4_OK (0)
        Opcode: OPEN (18)
            Status: NFS4_OK (0)
            stateid
                [StateID Hash: 0xaf36]
                seqid: 0x00000001
                Data: 01db0fb0ac64000000000000
            change_info
                Atomic: Yes
                changeid (before): 5901652787232948527
                changeid (after): 5901653255478300828
            results_flags: Unknown (0x00000006)
                .... .... .... .... .... .... .... ...0 = mlock: Unknown (0)
                .... .... .... .... .... .... .... ..1. = confirm: OPEN4_RESULT_MLOCK (1)
            Attr mask[0]: 0x00000010 (SIZE)
                reqd_attr: SIZE (4)
                    size: 42949672960
            Attr mask[1]: 0x00000002 (MODE)
                reco_attr: MODE (33)
                    fattr4_mode: 044
                        .... .... .... .... 000. .... .... .... = Name: Unknown (0)
                        .... .... .... .... .... 0... .... .... = Set user id on exec: No
                        .... .... .... .... .... .0.. .... .... = Set group id on exec: No
                        .... .... .... .... .... ..0. .... .... = Save swapped text even after use: No
                        .... .... .... .... .... ...0 .... .... = Read permission for owner: No
                        .... .... .... .... .... .... 0... .... = Write permission for owner: No
                        .... .... .... .... .... .... .0.. .... = Execute permission for owner: No
                        .... .... .... .... .... .... ..1. .... = Read permission for group: Yes
                        .... .... .... .... .... .... ...0 .... = Write permission for group: No
                        .... .... .... .... .... .... .... 0... = Execute permission for group: No
                        .... .... .... .... .... .... .... .1.. = Read permission for others: Yes
                        .... .... .... .... .... .... .... ..0. = Write permission for others: No
                        .... .... .... .... .... .... .... ...0 = Execute permission for others: No
            Delegation Type: Unknown (2950154659)
    [Main Opcode: OPEN (18)]
    Data (216 bytes)

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




