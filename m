Return-Path: linux-nfs-owner@vger.kernel.org
Received: from engine01-30064-1.icritical.com ([151.236.209.28]:53977 "HELO
	engine01-30064-1.icritical.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753851AbaCJRc6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Mar 2014 13:32:58 -0400
Received: from engine01-30064-1.icritical.com ([127.0.0.1])
 by localhost (engine01-30064-1.icritical.com [127.0.0.1]) (amavisd-new, port 10024)
 with SMTP id 09602-04 for <linux-nfs@vger.kernel.org>;
 Mon, 10 Mar 2014 17:26:13 +0000 (GMT)
Message-ID: <531DF5B4.9050001@pml.ac.uk>
Date: Mon, 10 Mar 2014 17:26:12 +0000
From: Ben Taylor <benj@pml.ac.uk>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: NFS4 patch 08/20 (BAD_SEQID recovery)
References: <53199445.3010808@pml.ac.uk> <69B89FEE-5B58-468F-95CE-B384033B2E65@primarydata.com>
In-Reply-To: <69B89FEE-5B58-468F-95CE-B384033B2E65@primarydata.com>
Content-Type: multipart/mixed;
	boundary="------------000501060508090201040405"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--------------000501060508090201040405
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

Hi Trond

On 07/03/14 13:05, Trond Myklebust wrote:
>> Can anyone tell me what happened to this patch please? Was it lost or
>> > superseded?
> It was superseded by commit 95b72eb0bdef6 (NFSv4: Ensure we do not reuse open owner names), which is available in linux 3.4 and newer.

Many thanks. That's a puzzle then, because we're running 3.9 and up and
already have that patch (I've checked).

I've attached my Wireshark dump (or at least a subset of it -
unfortunately I don't have the original call, the dump I've got is all
the same) - don't know if this tells you anything it doesn't tell me?
I'm not exactly experienced at reading these things!

Thanks
Ben

-- 
Ben Taylor <benj@pml.ac.uk>, http://rsg.pml.ac.uk/
Remote Sensing Group, Plymouth Marine Laboratory
Tel: +44 (0)1752 633432, Fax: +44 (0)1752 633101


Please visit our new website at www.pml.ac.uk and follow us on Twitter  @PlymouthMarine

Plymouth Marine Laboratory (PML) is a company limited by guarantee registered in England & Wales, company number 4178503. Registered Charity No. 1091222. Registered Office: Prospect Place, The Hoe, Plymouth  PL1 3DH, UK. 

This message is private and confidential. If you have received this message in error, please notify the sender and remove it from your system. You are reminded that e-mail communications are not secure and may contain viruses; PML accepts no liability for any loss or damage which may be caused by viruses.


--------------000501060508090201040405
Content-Type: application/vnd.tcpdump.pcap; name="nfs_bad_seqid_trimmed.dmp"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="nfs_bad_seqid_trimmed.dmp"

1MOyoQIABAAAAAAAAAAAAP//AAABAAAA6kQYU8XzCwBCAQAAQgEAAFiNCRhmwdBn5e50wAgA
RQABNCKMQABABp2DCgoKPcCrpMIDkggBCfy4m81Uj/qAGACTetsAAAEBCAprRFcwJ8EsboAA
APwgh+6pAAAAAAAAAAIAAYajAAAABAAAAAEAAAABAAAALABc/xAAAAAKZ3JpZG5vZGU1MQAA
AABCogAAOtEAAAADAAA60QAAYbMAAGl6AAAAAAAAAAAAAAAAAAAAAAAAAAUAAAAWAAAAHAEA
BgEk2SHln1lHJaY7i7yvYh0hZ0CjEaWQT/cAAAASAADteAAAAAEAAAAAkhYOU6kAAAAAAAAY
b3BlbiBpZDoAAAAsAAAABAAGOjFKJCJJAAAAAAAAAAIAAAAAkhYOU1fInQEAAAAAAAAACmlk
bF9wbmcuc28AAAAAAAoAAAADAAAALQAAAAkAAAACABABGgAwojrqRBhTHfQLAHoAAAB6AAAA
0Gfl7nTAWI0JGGbBCABFAABsiXVAAD8GOGLAq6TCCgoKPQgBA5LNVI/6Cfy5m4AYDCjPnQAA
AQEICifBLG5rRFcwgAAANCCH7qkAAAABAAAAAAAAAAAAAAAAAAAAAAAAJyoAAAAAAAAAAgAA
ABYAAAAAAAAAEgAAJyrqRBhTSfQLAEIBAABCAQAAWI0JGGbB0Gfl7nTACABFAAE0Io1AAEAG
nYIKCgo9wKukwgOSCAEJ/LmbzVSQMoAYAJN62wAAAQEICmtEVzAnwSxugAAA/CGH7qkAAAAA
AAAAAgABhqMAAAAEAAAAAQAAAAEAAAAsAFz/EAAAAApncmlkbm9kZTUxAAAAAEKiAAA60QAA
AAMAADrRAABhswAAaXoAAAAAAAAAAAAAAAAAAAAAAAAABQAAABYAAAAcAQAGASTZIeWfWUcl
pjuLvK9iHSFnQKMRpZBP9wAAABIAAO14AAAAAQAAAACSFg5TqQAAAAAAABhvcGVuIGlkOgAA
ACwAAAAEAAY6MUokIkkAAAAAAAAAAgAAAACSFg5TV8idAQAAAAAAAAAKaWRsX3BuZy5zbwAA
AAAACgAAAAMAAAAtAAAACQAAAAIAEAEaADCiOupEGFO99AsAegAAAHoAAADQZ+XudMBYjQkY
ZsEIAEUAAGyJdkAAPwY4YcCrpMIKCgo9CAEDks1UkDIJ/LqbgBgMKM1lAAABAQgKJ8EsbmtE
VzCAAAA0IYfuqQAAAAEAAAAAAAAAAAAAAAAAAAAAAAAnKgAAAAAAAAACAAAAFgAAAAAAAAAS
AAAnKupEGFPu9AsAQgEAAEIBAABYjQkYZsHQZ+XudMAIAEUAATQijkAAQAadgQoKCj3Aq6TC
A5IIAQn8upvNVJBqgBgAk3rbAAABAQgKa0RXMSfBLG6AAAD8IofuqQAAAAAAAAACAAGGowAA
AAQAAAABAAAAAQAAACwAXP8QAAAACmdyaWRub2RlNTEAAAAAQqIAADrRAAAAAwAAOtEAAGGz
AABpegAAAAAAAAAAAAAAAAAAAAAAAAAFAAAAFgAAABwBAAYBJNkh5Z9ZRyWmO4u8r2IdIWdA
oxGlkE/3AAAAEgAA7XgAAAABAAAAAJIWDlOpAAAAAAAAGG9wZW4gaWQ6AAAALAAAAAQABjox
SiQiSQAAAAAAAAACAAAAAJIWDlNXyJ0BAAAAAAAAAAppZGxfcG5nLnNvAAAAAAAKAAAAAwAA
AC0AAAAJAAAAAgAQARoAMKI66kQYU0r1CwB6AAAAegAAANBn5e50wFiNCRhmwQgARQAAbIl3
QAA/BjhgwKukwgoKCj0IAQOSzVSQagn8u5uAGAwoyywAAAEBCAonwSxua0RXMYAAADQih+6p
AAAAAQAAAAAAAAAAAAAAAAAAAAAAACcqAAAAAAAAAAIAAAAWAAAAAAAAABIAACcq
--------------000501060508090201040405--
