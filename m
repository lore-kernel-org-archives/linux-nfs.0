Return-Path: linux-nfs-owner@vger.kernel.org
Received: from DILBERT.FHCRC.ORG ([140.107.152.15]:33197 "EHLO
	dilbert.fhcrc.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab2E2NHi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2012 09:07:38 -0400
Received: from dilbert.fhcrc.org (localhost.localdomain [127.0.0.1])
	by localhost (Postfix) with SMTP id E0746A1C43
	for <linux-nfs@vger.kernel.org>; Tue, 29 May 2012 06:07:35 -0700 (PDT)
Received: from zimbra-mta2.fhcrc.org (ZIMBRA-MTA2.FHCRC.ORG [140.107.89.47])
	by dilbert.fhcrc.org (Postfix) with ESMTP id B6560A1AF1
	for <linux-nfs@vger.kernel.org>; Tue, 29 May 2012 06:07:35 -0700 (PDT)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by zimbra-mta2.fhcrc.org (Postfix) with ESMTP id A8455118002
	for <linux-nfs@vger.kernel.org>; Tue, 29 May 2012 06:07:35 -0700 (PDT)
Received: from zimbra-mta2.fhcrc.org ([127.0.0.1])
	by localhost (zimbra-mta2.fhcrc.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id VoT6l3rDUMRn for <linux-nfs@vger.kernel.org>;
	Tue, 29 May 2012 06:07:35 -0700 (PDT)
Received: from [140.107.9.116] (SHAKTI.FHCRC.ORG [140.107.9.116])
	by zimbra-mta2.fhcrc.org (Postfix) with ESMTPSA id 6501D118001
	for <linux-nfs@vger.kernel.org>; Tue, 29 May 2012 06:07:35 -0700 (PDT)
Message-ID: <4FC4CA16.8080606@fhcrc.org>
Date: Tue, 29 May 2012 06:07:34 -0700
From: Stuart Kendrick <skendric@fhcrc.org>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: ls stalls
References: <4FB43655.5040907@fhcrc.org> <4FB4397A.6060104@fhcrc.org> <C7DE94F7-9A05-43C1-81EF-10136AE3394E@oracle.com> <4FB4F932.8060104@fhcrc.org>
In-Reply-To: <4FB4F932.8060104@fhcrc.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> My starting guess is that there is some task on that client that has dirtied the pages of one of the files in the directory you are trying to list.
A GETATTR is required to flush outstanding writes to a file so the
server can provide size and mtime attributes that reflect the last most
recent write to that file.
>>
>> Possible work-arounds: You can reduce the dirty_ratio setting on the client to force it to starting flushing outstanding writes sooner, you can change the writing applications to use synchronous writes (or flush manually), or you can alter your "ls" command so that it doesn't require a GETATTR for each file.
>>

OK, I think I understand that if I've dirtied the pages on a file and
then issue a stat against it, that the NFS Client will stall my stat
until it flushes cache.

And I'm focused on the work-around of:  "You can reduce the dirty_ratio
setting ..."

(a) Does the stat /trigger/ a cache flush?  Or does the stat have to
wait for the usual mechanisms to initiate a flush?

(b) How granular is this process?  Will the NFS Client issue my stat
(GETATTR) once all the dirty pages relevant to my particular file are
flushed (but other pages are still being written)?  Or does the NFS
Client wait until pdflush has entirely emptied cache before proceeding
with the stat?

(c) When cache hits dirty_ratio (or dirty_bytes), I believe the kernel
blocks /all/ writers until it has /emptied/ cache (and flushing a big
cache to slow storage can take a while) ... am I correct?

(d) If my load is dominated by large writes over NFS, does cache buy me
anything?  Seems to me that the dominant benefit of cache is elevatoring
... the block structure of storage accessible via NFS is opaque ...
thus, there's nothing write cache can do to increase the performance of
the write ... it may as well hand off the blocks in any old order to the
NFS server and let the storage's cache worry about sequencing the blocks.

==> Seems to me that shrinking dirty_xxx to something really low ...
like 100K ... would:
(1) maximize 'stat' performance during heavy writes
(2) leave NFS write performance unaffected

but I can tell that I'm missing something here (because when I try it,
interactive performance, i.e. 'ls -l', tanks).  What am I not understanding?

--sk
