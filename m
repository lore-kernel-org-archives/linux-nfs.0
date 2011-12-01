Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:50060 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429Ab1LAK0y convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 05:26:54 -0500
Received: by dadv6 with SMTP id v6so177936dad.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2011 02:26:53 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 1 Dec 2011 15:43:03 +0530
Message-ID: <CAHbZLqTLHo7FYKmLUbi5OP4=8_O+obOvtFR=6+Dfs+tozJiwKA@mail.gmail.com>
Subject: need help for locking with nfs4
From: Upendra Moturi <upendra.m@hexagrid.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

I need some example to configure nfs4 mandatory locking.
I have setup nfs4 server and client.
I want to enable mandatory locking so that no two clients can access
file at same time.
Please guide me.
I working on ubuntu 10.04 and kernel 2.6.32-21-server.

-- 
Thanks and Regards,
Upendra.M

As a leading developer of IT infrastructure software solutions,
Hexagrid developed the first cloud computing platform that directly
aligns with the real-world IT delivery models of both solution
providers and enterprises. Hexagrid provides all the software and
support that IT organizations need to successfully build public,
private, or hybrid clouds that fit their specific business and
end-user requirements. Hexagrid cloud solutions truly simplify and
expedite virtual IT management, empowering successful cloud computing
strategies that quickly increase profits by pooling resources,
delivering control, and building value. Our Software, Your Cloud.  For
more information, visit www.hexagrid.com and follow @Hexagrid on
Twitter
