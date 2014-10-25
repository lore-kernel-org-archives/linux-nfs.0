Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:59137 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752232AbaJYTTv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 25 Oct 2014 15:19:51 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id C17DB280941
	for <linux-nfs@vger.kernel.org>; Sat, 25 Oct 2014 21:13:34 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id B2FA610F1
	for <linux-nfs@vger.kernel.org>; Sat, 25 Oct 2014 21:13:34 +0200 (MEST)
Received: from smtp-intra-3.desy.de (lb-40-26.desy.de) by ZITSWEEP1.win.desy.de
 (Clearswift SMTPRS 5.5.0) with ESMTP id <Tb6559101a183a9615f2b74@ZITSWEEP1.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Sat, 25 Oct 2014 21:13:34 +0200
Received: from z-mta-3.desy.de (z-mta-3.desy.de [131.169.55.137])
	by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id 0E1CE10F1
	for <linux-nfs@vger.kernel.org>; Sat, 25 Oct 2014 21:13:34 +0200 (MEST)
Received: from z-mta-3.desy.de (localhost [127.0.0.1])
	by z-mta-3.desy.de (Postfix) with ESMTP id 096B140084
	for <linux-nfs@vger.kernel.org>; Sat, 25 Oct 2014 21:13:34 +0200 (CEST)
Received: from z-mta-3.desy.de (localhost [127.0.0.1])
	by z-mta-3.desy.de (Postfix) with ESMTP id ECFAD400B9
	for <linux-nfs@vger.kernel.org>; Sat, 25 Oct 2014 21:13:33 +0200 (CEST)
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
	by z-mta-3.desy.de (Postfix) with ESMTP id E566940084
	for <linux-nfs@vger.kernel.org>; Sat, 25 Oct 2014 21:13:33 +0200 (CEST)
Date: Sat, 25 Oct 2014 21:13:33 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Message-ID: <340559201.872226.1414264413792.JavaMail.zimbra@desy.de>
In-Reply-To: <74264531.872138.1414263726250.JavaMail.zimbra@desy.de>
Subject: lua extention for wireshak to trace nfs server latencies
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Dear NFS fellows,

recently I was debugging some NFS related issues and
needed a tool to trace situations when NFS server is slow.

I created a lua extension for tshark which allows to get
such information, but still has the full power of tshark.

example usage:


# for life capture
$ tshark -q -X lua_script:nfs.lua -f "port 2049"

# for a capture file
$ tshark -q -r nfs.dump -X lua_script:nfs.lua

the output looks like:

       timestamp                        client ip                 server ip             time  OP

"Aug 27, 2014 16:44:43.000 CEST" aaaa:bbbb:ccc:10a0::1:7f <=> aaaa:bbbb:ccc:10bf::1:8c 0.001 v4_EXCHANGE_ID
"Aug 27, 2014 16:44:43.000 CEST" aaaa:bbbb:ccc:10a0::1:7f <=> aaaa:bbbb:ccc:10bf::1:8c 0.001 v4_CREATE_SESSION
"Aug 27, 2014 16:44:43.000 CEST" aaaa:bbbb:ccc:10a0::1:7f <=> aaaa:bbbb:ccc:10bf::1:8c 0.001 v4_PUTROOTFH
"Aug 27, 2014 16:44:43.000 CEST" aaaa:bbbb:ccc:10a0::1:7f <=> aaaa:bbbb:ccc:10bf::1:8c 0.002 v4_RECLAIM_COMPLETE
"Aug 27, 2014 16:44:43.000 CEST" aaaa:bbbb:ccc:10a0::1:7f <=> aaaa:bbbb:ccc:10bf::1:8c 0.001 v4_PUTROOTFH
"Aug 27, 2014 16:44:43.000 CEST" aaaa:bbbb:ccc:10a0::1:7f <=> aaaa:bbbb:ccc:10bf::1:8c 0.001 v4_DESTROY_SESSION
"Aug 27, 2014 16:44:43.000 CEST" a.b.161.127 <=> a.b.191.140 0.001 v4_EXCHANGE_ID
"Aug 27, 2014 16:44:43.000 CEST" a.b.161.127 <=> a.b.191.140 0.001 v4_CREATE_SESSION
"Aug 27, 2014 16:44:43.000 CEST" a.b.161.127 <=> a.b.191.140 0.003 v4_PUTROOTFH
"Aug 27, 2014 16:44:43.000 CEST" a.b.161.127 <=> a.b.191.140 0.002 v4_RECLAIM_COMPLETE
"Aug 27, 2014 16:44:43.000 CEST" a.b.161.127 <=> a.b.191.140 0.004 v4_PUTROOTFH


May be some one need's it as well:  https://github.com/kofemann/wireshark_lua


P.S.: is it the right place for such posts or there yet another mailing list or wiki?

Thanks,
   Tigran.
