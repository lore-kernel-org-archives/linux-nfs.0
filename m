Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36806 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751114Ab1AaPnT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Jan 2011 10:43:19 -0500
Date: Mon, 31 Jan 2011 10:43:18 -0500
To: =?utf-8?B?xYF1a2FzeiBPbGXFmw==?= <lukasz.oles@open-e.com>
Cc: linux-nfs@vger.kernel.org, Artur Piechocki <artur.piechocki@open-e.com>
Subject: Re: Testing sm-notify
Message-ID: <20110131154318.GC30447@fieldses.org>
References: <201101311045.02517.lukasz.oles@open-e.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <201101311045.02517.lukasz.oles@open-e.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jan 31, 2011 at 10:45:01AM +0100, Łukasz Oleś wrote:
> Hello,
> 
> I am using nfs-utils version 1.2.3. I am trying to test sm-notify, I have 2 
> test scenarios:
> 
> First one:
> 1 server, 2 clients - client 1 locks file on nfs server, client 2 is trying to 
> lock the same file and waiting.  I'm restarting client 1, client 2 locks file.
> Everything works fine
> 
> Second:
> 1 server, 1 client - client locks file. I'm restarting server and  client 
> should relock file, but I don't know any program which can do it. 
> 
> How do you testing this scenario? Can you recommend any program which can 
> automaticly lock file again?

I don't understand the question.

One way to test that behavior is correct might be using 2 clients:
client 1 acquires lock, server reboots, then client 2 requests same
lock after reboot.  If client 1 managed to reacquire the lock during the
grace period, then client 2's lock request should continue to block.

--b.
