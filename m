Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33479 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752682AbdFUIhJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jun 2017 04:37:09 -0400
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v5L8b8RS004802
        (version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Wed, 21 Jun 2017 08:37:08 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0021.oracle.com (8.13.8/8.14.4) with ESMTP id v5L8b8U1020553
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Wed, 21 Jun 2017 08:37:08 GMT
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id v5L8b7Fa008961
        for <linux-nfs@vger.kernel.org>; Wed, 21 Jun 2017 08:37:07 GMT
Reply-To: emmanuel.jannetti@oracle.com
To: linux-nfs@vger.kernel.org
From: "emmanuel.jannetti@oracle.com" <emmanuel.jannetti@oracle.com>
Subject: getting per export entry statistics
Message-ID: <e9f5bc8a-91c7-21e8-b22b-cbd7e2347a65@oracle.com>
Date: Wed, 21 Jun 2017 10:37:06 +0200
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------1DB1825886DF336A9A490BB4"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------1DB1825886DF336A9A490BB4
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi all,


I am looking for a way to know (from NFS server point of view) that an exported directory is actually in use.
I mean not only remotely mounted but have some activity happening on it.

All commands combination I've tried (nfsstat, showmount etc…) do not give all the information. Or overall NFS clients
information digging into /proc files did not help neither.

Thank in advance fo any help

Regards
EJ


--------------1DB1825886DF336A9A490BB4
Content-Type: text/x-vcard; charset=utf-8;
 name="emmanuel_jannetti.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="emmanuel_jannetti.vcf"

begin:vcard
fn:Emmanuel Jannetti
n:Jannetti;Emmanuel
adr:;;180 Avenue de l'Europe;Montbonnot;;38330;France
email;internet:emmanuel.jannetti@oracle.com
tel;work:x38101
x-mozilla-html:TRUE
url:https://blogs.oracle.com/ejannett/
version:2.1
end:vcard


--------------1DB1825886DF336A9A490BB4--
