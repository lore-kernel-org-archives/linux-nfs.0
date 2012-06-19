Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:35272 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751300Ab2FSJ7H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jun 2012 05:59:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1SgvDC-0006G3-OU
	for linux-nfs@vger.kernel.org; Tue, 19 Jun 2012 11:59:02 +0200
Received: from bg-1.or.uni-bonn.de ([131.220.141.100])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 19 Jun 2012 11:59:02 +0200
Received: from bartoschek by bg-1.or.uni-bonn.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 19 Jun 2012 11:59:02 +0200
To: linux-nfs@vger.kernel.org
From: Christoph Bartoschek <bartoschek@gmx.de>
Subject: Spurious permission denied
Date: Tue, 19 Jun 2012 11:58:27 +0200
Message-ID: <43v5b9-ifa.ln1@barney.bruehl.pontohonk.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nextPart2182644.tDU5xdFZgO"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--nextPart2182644.tDU5xdFZgO
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7Bit

Hi,

we still have the problem that some users get permission denied for 
directories they normally can access. The problem only affects a single user 
at a time and automatically goes away after about 30 minutes.

It seems to be a server problem because this happens on all client machines 
at the same time.

Here is how it looks like:

[bartosch@r1106i12 ~]$ ls /afs/eda/prod
ls: cannot open directory /afs/eda/prod: Permission denied
[bartosch@r1106i12 ~]$ id
uid=348(bartosch) gid=200(vls) 
groups=200(vlsi),100(users),201(zab),900(ibm),901(iba),902(ama),1001(eda),2030(asi),2057(ecl),41999(tra)
[bartosch@r1106i12 ~]$ 

I have attached the network traffic that was exchanged between the NFS 
server and the client for the ls command captured by wireshark.

Accessing the directory /afs/eda works as expected.

Has anyone an idea what could be wrong?

Thanks,
Christoph Bartoschek
--nextPart2182644.tDU5xdFZgO
Content-Type: application/vnd.tcpdump.pcap; name="network_traffic.dump"
Content-Disposition: attachment; filename="network_traffic.dump"
Content-Transfer-Encoding: base64

1MOyoQIABAAAAAAAAAAAAP//AAABAAAAvUngT9jRDgDGAAAAxgAAAAAwSNQccAAlkCyl8AgARQAA
uCa7QABABnMbwKiPNMCoj+QCvQgBEVj0a6Z+mPyAGF/7oRQAAAEBCArYUJf2G9FT94AAAICJbqJY
AAAAAAAAAAIAAYajAAAAAwAAAAEAAAABAAAARAB46Z8AAAAIcjExMDZpMTIAAAFcAAAAyAAAAAoA
AABkAAAAyAAAAMkAAAOEAAADhQAAA4YAAAPpAAAH7gAACAkAAKQPAAAAAAAAAAAAAAAQAQABAQEA
AAACANgPRVkyJr1J4E9p0g4AtgAAALYAAAAAJZAspfAAMEjUHHAIAEUAAKg8PUAAQAZdqcCoj+TA
qI80CAECvaZ+mPwRWPTvgBgB9TP4AAABAQgKG9FcxthQl/aAAABwiW6iWAAAAAEAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAIAAEXoAAAARwAAA+wAAAPpAAAAAAAAEAAAAAAAAAAQAAAAAAAAAAAAAAAA
AAAAAAEAAAAAD9gAAk/fBq04owRBT3MMIAAAAABPeZD9FZdXXr1J4E940g4AQgAAAEIAAAAAMEjU
HHAAJZAspfAIAEUAADQmvEAAQAZznsCojzTAqI/kAr0IARFY9O+mfplwgBBf+6CQAAABAQgK2FCX
9hvRXMY=

--nextPart2182644.tDU5xdFZgO--


