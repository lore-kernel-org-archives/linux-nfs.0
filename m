Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20803 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754426Ab2BAT0j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Feb 2012 14:26:39 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q11JQUop014330
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 1 Feb 2012 14:26:39 -0500
Received: from [10.33.0.52] (sprabhu.fab.redhat.com [10.33.0.52])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q11HULcH029422
	for <linux-nfs@vger.kernel.org>; Wed, 1 Feb 2012 12:30:21 -0500
Subject: stateid sequence numbers
From: Sachin Prabhu <sprabhu@redhat.com>
To: linux-nfs@vger.kernel.org
Date: Wed, 01 Feb 2012 17:30:20 +0000
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1328117421.17411.15.camel@sprabhu.fab.redhat.com>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is there any reason we need to treat the stateid as an opaque object in
NFSv4?

The RFC states the following
--
RFC 3530 -  Page 23

   stateid4

                  struct stateid4 {
                    uint32_t        seqid;
                    opaque          other[12];
                  };

   This structure is used for the various state sharing mechanisms
   between the client and server.  For the client, this data structure
   is read-only.  The starting value of the seqid field is undefined.
   The server is required to increment the seqid field monotonically at
   each transition of the stateid.  This is important since the client
   will inspect the seqid in OPEN stateids to determine the order of
   OPEN processing done by the server.
--

We have a user report a problem for which we believe we need to check
the version of the stateid by taking a look at the sequence id reported
for that state. Is there a good reason why this should be opaque?

Sachin Prabhu

