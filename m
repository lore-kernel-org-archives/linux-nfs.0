Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:2958 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752302AbaFJThn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2014 15:37:43 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] NFS test SECINFO RPC_AUTH_GSS pseudoflavors for
 support
Date: Tue, 10 Jun 2014 19:37:18 +0000
Message-ID: <F9B31697-0CDD-4E03-B8F7-383DC9CE8D8C@netapp.com>
References: <1402342401-5640-1-git-send-email-andros@netapp.com>
 <1402342401-5640-4-git-send-email-andros@netapp.com>
 <1402417268.2577.4.camel@leira.trondhjem.org>
 <43CD0281-BAB1-4E29-A51C-876A017F4374@netapp.com>
 <CAHQdGtQd2C2LLCoxNLLYiLA-iJd8kGoeRTZ3vr6AF5j5gM046A@mail.gmail.com>
In-Reply-To: <CAHQdGtQd2C2LLCoxNLLYiLA-iJd8kGoeRTZ3vr6AF5j5gM046A@mail.gmail.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 10, 2014, at 3:29 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Tue, Jun 10, 2014 at 2:38 PM, Adamson, Andy
> <William.Adamson@netapp.com> wrote:
>> 
>> On Jun 10, 2014, at 12:21 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>> 
>>> On Mon, 2014-06-09 at 15:33 -0400, andros@netapp.com wrote:
>>>> From: Andy Adamson <andros@netapp.com>
>>>> 
>>>> The current code returns an RPC_AUTH_GSS pseudo-flavor without testing to see
>>>> if it is configured properly. If an RPC_AUTH_GSS pseudoflavor fails then the
>>>> next SECINFO flavor should be tried.
>>>> 
>>>> Create an rpc_auth, rpc_cred, and initialize the cred (e.g. get a GSS Context)
>>>> using the short-lived SECINFO rpc client to test if the use of the RPC_AUTH_GSS
>>>> pseudoflavor succeeds.
>>>> 
>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>> ---
>>>> fs/nfs/nfs4namespace.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++--
>>>> 1 file changed, 46 insertions(+), 2 deletions(-)
>>>> 
>>>> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
>>>> index fd4dcb6..e0a5491 100644
>>>> --- a/fs/nfs/nfs4namespace.c
>>>> +++ b/fs/nfs/nfs4namespace.c
>>>> @@ -135,6 +135,39 @@ static size_t nfs_parse_server_name(char *string, size_t len,
>>>> }
>>>> 
>>>> /**
>>>> + * nfs_test_gss - Test client support of pseudoflavor
>>>> + * @server: NFS server struct
>>>> + * @flavor: RPC_AUTH_GSS pseudoflavor
>>>> + */
>>>> +
>>>> +static int nfs_test_gss_flavor(struct nfs_server *server,
>>>> +                           rpc_authflavor_t pseudoflavor)
>>>> +{
>>>> +    struct rpc_auth_create_args auth_args = {
>>>> +            .pseudoflavor = pseudoflavor,
>>>> +    };
>>>> +    struct rpc_auth *auth;
>>>> +    struct rpc_cred *rcred;
>>>> +    const struct cred *cred = current_cred();
>>>> +    struct auth_cred acred = {
>>>> +            .uid = cred->fsuid,
>>>> +            .gid = cred->fsgid,
>>>> +            .group_info = get_group_info(((struct cred *)cred)->group_info),
>>>> +    };
>>>> +
>>>> +    auth = rpcauth_create(&auth_args, server->client);
>>> 
>>> This call has the side-effect of changing the value of
>>> server->client->cl_auth. Not sure that we want that here.
>> 
>> I don't see any other interface to get a gss_auth struct to pass to rpcauth_lookupcredcache.
>> 
>> If the gss_cred/gss_context creation works, then the cl_auth being set is OK as it would have been set anyway by the callers of nfs4_negotiate_security (nfs4_submount or nfs4_create_sec_client so far) if we simply passed the flavor to those functions to “test” if RPC_AUTH_GSS can be used.
> 
> Looking at the callers, I think I disagree. They are both trying to do
> lookups, so the WRONGSEC error that we're handling applies to the
> object being looked up, and not to the parent directory or the struct
> nfs_server that is being passed as an argument to nfs_find_best_sec().

Ah. So I should clone a client to test the RPC_AUTH_GSS SECINFO case…

—>Andy

> 
> -- 
> Trond Myklebust
> 
> Linux NFS client maintainer, PrimaryData
> 
> trond.myklebust@primarydata.com

