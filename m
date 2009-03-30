From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 05/46] nfs41: add mount command option minorversion
Date: Mon, 30 Mar 2009 11:01:18 +0300
Message-ID: <49D07C4E.3000508@panasas.com>
References: <49ADBD04.2090002@panasas.com>	 <1236124351-3116-1-git-send-email-bhalevy@panasas.com> <1238343501.10999.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:29475 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751725AbZC3ICN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 04:02:13 -0400
In-Reply-To: <1238343501.10999.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 29, 2009, 19:18 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Tue, 2009-03-03 at 16:52 -0700, Benny Halevy wrote:
>> From: Mike Sager <sager@netapp.com>
>>
>> mount -t nfs4 -o minorversion=[0|1] specifies whether to use 4.0 or
>> 4.1.
>> By default, the minorversion is set to 0.
>>
>> Signed-off-by: Mike Sager <sager@netapp.com>
>> [set default minorversion to 0 as per Trond and SteveD's request]
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/internal.h |    1 +
>>  fs/nfs/super.c    |   10 ++++++++++
>>  2 files changed, 11 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> index 340ede8..73e4d9f 100644
>> --- a/fs/nfs/internal.h
>> +++ b/fs/nfs/internal.h
>> @@ -41,6 +41,7 @@ struct nfs_parsed_mount_data {
>>         unsigned int            auth_flavor_len;
>>         rpc_authflavor_t        auth_flavors[1];
>>         char                    *client_address;
>> +       unsigned int            minorversion;
>>
>>         struct {
>>                 struct sockaddr_storage address;
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index d6686f4..5db4e3b 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -88,6 +88,7 @@ enum {
>>         Opt_mountport,
>>         Opt_mountvers,
>>         Opt_nfsvers,
>> +       Opt_minorversion,
>>
>>         /* Mount options that take string arguments */
>>         Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
>> @@ -149,6 +150,7 @@ static const match_table_t nfs_mount_option_tokens
>> = {
>>         { Opt_mountvers, "mountvers=%u" },
>>         { Opt_nfsvers, "nfsvers=%u" },
>>         { Opt_nfsvers, "vers=%u" },
>> +       { Opt_minorversion, "minorversion=%u" },
>>
>>         { Opt_sec, "sec=%s" },
>>         { Opt_proto, "proto=%s" },
>> @@ -1168,6 +1170,13 @@ static int nfs_parse_mount_options(char *raw,
>>                                 nfs_parse_invalid_value("nfsvers");
>>                         }
>>                         break;
>> +               case Opt_minorversion:
>> +                       if (match_int(args, &option))
>> +                               return 0;
>> +                       if (option < 0 || option >
>> NFS4_MAX_MINOR_VERSION)
>> +                               return 0;
>> +                       mnt->minorversion = option;
> 
> There is nothing preventing the user from setting this on NFSv2 or
> NFSv3. That will cause nfs_match_client() to get confused. 

Not really, because nfs_init_server ignores it.
The question still is whether we should prevent the user from
setting it for NFSv[23].  FWIW, we don't do that kind of validation
for other mount options, e.g. those referring to the mount protocol.

Benny

> 
>> +                       break;
>>
>>                 /*
>>                  * options that take text values
>> @@ -2218,6 +2227,7 @@ static int nfs4_validate_mount_data(void
>> *options,
>>         args->nfs_server.port   = NFS_PORT; /* 2049 unless user set
>> port= */
>>         args->auth_flavors[0]   = RPC_AUTH_UNIX;
>>         args->auth_flavor_len   = 0;
>> +       args->minorversion      = 0;
>>
>>         switch (data->version) {
>>         case 1:
>> --
>> 1.6.1.3
>>
>>
>>
