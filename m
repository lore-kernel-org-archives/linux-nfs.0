From: Juan Gomez <juang@us.ibm.com>
Subject: Non-blocking lock requests during the grace period
Date: Thu, 14 Nov 2002 11:56:42 -0800
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <OFCACC2A48.A38B3611-ON87256C71.006D0CEB@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: nfs@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>






I found out that the current Linux client of lockd blocks non-blocking lock
requests while the server is in the grace period.
I think this is incorrect behavior and I am wondering if the will exists
out there to correct this and return "resource not available"
to the process when a request is for a *non-blocking* lock while the server
is in the grace period.

It is extremelly odd to issue a *non-blocking* call and be blocked in the
kernel for about a minute when the server happens
to be in the grace period.

This consists of a minor change to nlmclnt_call() and I would send the
patch if someone will review and include it.

Regards, Juan
