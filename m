Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og112.obsmtp.com ([64.18.0.24]:54521 "HELO
	exprod5og112.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751979Ab0JMUez (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Oct 2010 16:34:55 -0400
Message-ID: <4CB617ED.4000504@panasas.com>
Date: Wed, 13 Oct 2010 16:34:53 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/5] NFS: clear fsinfo before sendign rpc
References: <4CA31DC3.8070300@panasas.com>	<1285758613-26897-1-git-send-email-bhalevy@panasas.com> <AANLkTim8BCOgLNXZt3QKLX=g1dEruNEWHsb2GPs2AVYD@mail.gmail.com>
In-Reply-To: <AANLkTim8BCOgLNXZt3QKLX=g1dEruNEWHsb2GPs2AVYD@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-13 14:03, Fred Isaman wrote:
> On Wed, Sep 29, 2010 at 7:10 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>> To initialize all values to zero, in case the server or protocol version
>> do no support particular attributes.
> 
> Sorry for the delayed response, but...
> 
> Zero is not an appropriate default for many of the values.  Further,
> decode_fsinfo sets a default for each value, even in cases where the
> server or protocol version do not support particular attributes.  So
> this patch seems to server no purpose.

Note that nfs_probe_fsinfo is called also for nfs version 2 and 3
and these don't know anything about nfsv4.1 attributes so they can't
cannot explicitly set them to any default value.

Benny


> 
> Fred
> 
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/client.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>> index 23d740c..beb206e 100644
>> --- a/fs/nfs/client.c
>> +++ b/fs/nfs/client.c
>> @@ -942,6 +942,7 @@ static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, str
>>                        goto out_error;
>>        }
>>
>> +       memset(&fsinfo, 0, sizeof(fsinfo));
>>        fsinfo.fattr = fattr;
>>        error = clp->rpc_ops->fsinfo(server, mntfh, &fsinfo);
>>        if (error < 0)
>> --
>> 1.7.2.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
