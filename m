From: Bernd Schubert <bs-PKu+Ek1N2UGzQB+pC5nmwQ@public.gmane.org>
Subject: multiple instances of rpc.statd
Date: Fri, 25 Apr 2008 15:31:20 +0200
Message-ID: <200804251531.21035.bs@q-leap.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.q-leap.de ([153.94.51.193]:44888 "EHLO mail.q-leap.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754444AbYDYNbW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2008 09:31:22 -0400
Received: from lanczos (lanczos [192.168.55.86])
	by mail.q-leap.de (Postfix) with ESMTP id 789C99522
	for <linux-nfs@vger.kernel.org>; Fri, 25 Apr 2008 15:31:21 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

on servers with heartbeat managed resources one rather often has the situation 
one exports different directories from different resources.

It now may happen all resources are running on one host, but they can also run 
from different hosts. The situation gets even more complicated if the server 
is also a nfs client.

In principle having different nfs resources works fine, only the statd state 
directory is a problem. Or in principle the statd concept at all. Actually we 
would need to have several instances of statd running using different 
directories. These then would have to be migrated from one server to the 
other on resource movement. 
However, as far I understand it, there does not even exist the basic concept 
for this, doesn't it? 


Thanks,
Bernd



-- 
Bernd Schubert
Q-Leap Networks GmbH
