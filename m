Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:39219 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761726Ab2EQNqr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 09:46:47 -0400
Subject: Re: ls stalls
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FB4F932.8060104@fhcrc.org>
Date: Thu, 17 May 2012 09:46:42 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <A364E35B-CDE6-44D7-8D99-06EDB31666D7@oracle.com>
References: <4FB43655.5040907@fhcrc.org> <4FB4397A.6060104@fhcrc.org> <C7DE94F7-9A05-43C1-81EF-10136AE3394E@oracle.com> <4FB4F932.8060104@fhcrc.org>
To: Stuart Kendrick <skendric@fhcrc.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 17, 2012, at 9:12 AM, Stuart Kendrick wrote:

>> My starting guess is that there is some task on that client that has dirtied the pages of one of the files in the directory you are trying to list.  A GETATTR is required to flush outstanding writes to a file so the server can provide size and mtime attributes that reflect the last most recent write to that file.
>> 
>> Possible work-arounds: You can reduce the dirty_ratio setting on the client to force it to starting flushing outstanding writes sooner, you can change the writing applications to use synchronous writes (or flush manually), or you can alter your "ls" command so that it doesn't require a GETATTR for each file.
>> 
> How might I replicate this?
> 
> I'm trying a continuous write to a file ... but 'ls -l' remains snappy.

The file must reside in the directory you are listing, and it should be very large.  Typically dd'ing zeroes into a large file is a good way to starve non-writers.

> #!/bin/bash
> while [ true ]
> 	cp foo.1 foo.2
> 	echo Do it again
> done

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




