Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:37297 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaFEMyZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 08:54:25 -0400
Received: by mail-ie0-f180.google.com with SMTP id at20so626009iec.39
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 05:54:25 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH pynfs 01/17] 4.1 client: reclaim_complete after create_session
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20140605022640.GA12044@fieldses.org>
Date: Thu, 5 Jun 2014 08:54:23 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <4E48F0D6-DD84-4388-83A8-9D4084CCAC34@primarydata.com>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com> <1401915726-29092-2-git-send-email-dros@primarydata.com> <20140605022640.GA12044@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 4, 2014, at 10:26 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Wed, Jun 04, 2014 at 05:01:49PM -0400, Weston Andros Adamson wrote:
>> Send RECLAIM_COMPLETE after CREATE_SESSION. This enables backend
>> communication to v4.1 linux nfsd servers (i/o through MDS only).
> 
> If that's unconditionally adding a reclaim_complete after every
> create_sesion, that's probably not what we want since there are tests
> that want to do the reclaim_complete by hand.  You probably want to use
> new_client_session() instead?  See 219cf7b7f7d0 and the preceding
> commit.
> 
> —b.

Ok, thats a good point, but AFAIC new_client_session is never called - at least by
nfs4server.

I’ll figure out a better way to do this.

-dros

> 
>> 
>> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
>> ---
>> nfs4.1/nfs4client.py | 1 +
>> 1 file changed, 1 insertion(+)
>> 
>> diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
>> index e750728..0d94a42 100644
>> --- a/nfs4.1/nfs4client.py
>> +++ b/nfs4.1/nfs4client.py
>> @@ -367,6 +367,7 @@ class ClientRecord(object):
>>         self.seqid = inc_u32(csr.csr_sequence) # XXX Do we need to check this?
>>         sess = SessionRecord(csr, self)
>>         self.c.sessions[sess.sessionid] = sess
>> +        sess.compound([op.reclaim_complete(FALSE)])
>>         return sess
>> 
>>     def _cb_hook(self, prefix, opname, funct):
>> -- 
>> 1.8.5.2 (Apple Git-48)
>> 

