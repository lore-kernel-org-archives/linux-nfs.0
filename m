Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp3.ugent.be ([157.193.49.127]:59250 "EHLO smtp3.ugent.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753904Ab3DOPuw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Apr 2013 11:50:52 -0400
Received: from localhost (mcheck2.ugent.be [157.193.49.249])
	by smtp3.ugent.be (Postfix) with ESMTP id 0A87EC389
	for <linux-nfs@vger.kernel.org>; Mon, 15 Apr 2013 17:43:33 +0200 (CEST)
Received: from smtp3.ugent.be ([157.193.49.127])
	by localhost (mcheck2.UGent.be [157.193.43.11]) (amavisd-new, port 10024)
	with ESMTP id V7W-c_G0xWPi for <linux-nfs@vger.kernel.org>;
	Mon, 15 Apr 2013 17:43:32 +0200 (CEST)
Received: from localhost.localdomain (spike.ugent.be [157.193.44.183])
	(Authenticated sender: stdweird)
	by smtp3.ugent.be (Postfix) with ESMTPSA id C8476C36C
	for <linux-nfs@vger.kernel.org>; Mon, 15 Apr 2013 17:43:32 +0200 (CEST)
Message-ID: <516C2024.9030504@ugent.be>
Date: Mon, 15 Apr 2013 17:43:32 +0200
From: Stijn De Weirdt <stijn.deweirdt@ugent.be>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: replicas and client support
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi all,

(pls keep me in cc, i'm not subscribed to this list)

i am trying out the replicas feature of exportfs, but i'm unable to get 
it working.

i would like to know if what i'm trying to is actually implemented in 
linux (or intended behaviour of replicas in the first place).

2 nfs4 servers with cluster filesystem (gpfs in my case). the os is 
sl6.4, i've enabled the nfs version 4.1 on the server (from my 
understanding, 4.0 should be enough?).

i would like to test if the replicas features can be used for failover 
support of a rw nfs export. ie
a. mount nfs from server1 on client
b. start some IO activity on client on the mounted filesystem
c. poweroff server1
d. after a certain amount of time, IO continues using server2

(the client i'm testing with is also el6.4 atm.)


many thanks,

stijn
