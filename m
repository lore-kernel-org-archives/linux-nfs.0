Return-Path: linux-nfs-owner@vger.kernel.org
Received: from DOGBERT.FHCRC.ORG ([140.107.89.15]:43021 "EHLO
	dogbert.fhcrc.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759530Ab2EQNMU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 09:12:20 -0400
Message-ID: <4FB4F932.8060104@fhcrc.org>
Date: Thu, 17 May 2012 06:12:18 -0700
From: Stuart Kendrick <skendric@fhcrc.org>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: ls stalls
References: <4FB43655.5040907@fhcrc.org> <4FB4397A.6060104@fhcrc.org> <C7DE94F7-9A05-43C1-81EF-10136AE3394E@oracle.com>
In-Reply-To: <C7DE94F7-9A05-43C1-81EF-10136AE3394E@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> My starting guess is that there is some task on that client that has dirtied the pages of one of the files in the directory you are trying to list.  A GETATTR is required to flush outstanding writes to a file so the server can provide size and mtime attributes that reflect the last most recent write to that file.
> 
> Possible work-arounds: You can reduce the dirty_ratio setting on the client to force it to starting flushing outstanding writes sooner, you can change the writing applications to use synchronous writes (or flush manually), or you can alter your "ls" command so that it doesn't require a GETATTR for each file.
> 
How might I replicate this?

I'm trying a continuous write to a file ... but 'ls -l' remains snappy.

#!/bin/bash
while [ true ]
	cp foo.1 foo.2
	echo Do it again
done

--sk
