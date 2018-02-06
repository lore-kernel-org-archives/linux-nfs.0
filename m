Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:45223 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753329AbeBFWKV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Feb 2018 17:10:21 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id B494528044C
        for <linux-nfs@vger.kernel.org>; Tue,  6 Feb 2018 23:10:19 +0100 (CET)
Date: Tue, 6 Feb 2018 23:10:19 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Message-ID: <1253710805.3166627.1517955019275.JavaMail.zimbra@desy.de>
Subject: wrong latency info for flexfiles on layout return
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi Trond et al.

by exploring data provided on layoutreturn I can see that some
information is wrong, in particular the IO latency completition
time for write:

{
   "iostats":[
      {
         "deviceAddr":"tcp://192.168.178.40.128.2",
         "duration":{
            "seconds":5,
            "nseconds":285924462
         },
         "readInfo":{
            "bytes":0,
            "latency":{
               "completitionTime":{
                  "seconds":0,
                  "nseconds":0
               },
               "bytesRequested":0,
               "opsCompleted":0,
               "busyTime":{
                  "seconds":0,
                  "nseconds":0
               },
               "opsRequested":0,
               "bytesCompleted":0,
               "bytesNotDelivered":0
            },
            "count":0
         },
         "fh":"01caffee00000000b1f9635e000d00000800000000000000050130",
         "writeInfo":{
            "bytes":624193536,
            "latency":{
               "completitionTime":{
                  "seconds":25737,
                  "nseconds":816217921
               },
               "bytesRequested":624193536,
               "opsCompleted":9526,
               "busyTime":{
                  "seconds":5,
                  "nseconds":224017937
               },
               "opsRequested":9526,
               "bytesCompleted":624193536,
               "bytesNotDelivered":0
            },
            "count":9526
         },
         "deviceId":"00000001000000000000000000000000",
         "open-stateid":"5a7a259b0000000100000004"
      }
   ]
}


you can see this with wireshark as well.

Regards,
   Tigran.
