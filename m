Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:29609 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753475Ab0LPPy3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 10:54:29 -0500
Subject: Re: [PATCH] nfs4: set source address when callback is generated
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101216034945.GH9646@fieldses.org>
Date: Thu, 16 Dec 2010 10:54:00 -0500
Cc: Takuma Umeya <tumeya@redhat.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Message-Id: <A4BB9763-B67F-4559-B3FF-F7BC2DBD3B3A@oracle.com>
References: <20101215050901.GB13532@redhat.com> <20101216034945.GH9646@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 15, 2010, at 10:49 PM, J. Bruce Fields wrote:

> On Wed, Dec 15, 2010 at 02:09:01PM +0900, Takuma Umeya wrote:
>> when callback is generated in NFSv4 server, it doesn't set the source
>> address. When an alias IP is utilized on NFSv4 server and suppose the 
>> client is accessing via that alias IP (e.g. eth0:0), the client invokes 
>> the callback to the IP address that is set on the original device (e.g.
>> eth0). This behavior results in timeout of xprt. 
>> The patch sets the IP address that the client should invoke callback to. 
>> 
>> Signed-off-by: Takuma Umeya <tumeya@redhat.com>
>> 
>> 
>> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
>> index 143da2e..bb5de7f 100644
>> --- a/fs/nfsd/nfs4callback.c
>> +++ b/fs/nfsd/nfs4callback.c
>> @@ -483,6 +483,7 @@ int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
>>                .net            = &init_net,
>>                .address        = (struct sockaddr *) &conn->cb_addr,
>>                .addrsize       = conn->cb_addrlen,
>> +               .saddress       = (struct sockaddr *) &conn->cb_saddr,
>>                .timeout        = &timeparms,
>>                .program        = &cb_program,
>>                .version        = 0,
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 116cab9..c7d3171 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1177,9 +1177,11 @@ find_unconfirmed_client_by_str(const char *dname, unsigned int hashval,
>> }
>> 
>> static void
>> -gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, u32 scopeid)
>> +gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, 
>> +                                       u32 scopeid, struct svc_rqst *rqstp)
>> {
>>        struct nfs4_cb_conn *conn = &clp->cl_cb_conn;
>> +       struct sockaddr s_sa;
>>        unsigned short expected_family;
>> 
>>        /* Currently, we only support tcp and tcp6 for the callback channel */
>> @@ -1205,6 +1207,19 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, u32 scopeid)
>> 
>>        conn->cb_prog = se->se_callback_prog;
>>        conn->cb_ident = se->se_callback_ident;
>> +       switch(expected_family){
>> +               case AF_INET:
>> +                       ((struct sockaddr_in *)&s_sa)->sin_family = AF_INET;
>> +                       ((struct sockaddr_in *)&s_sa)->sin_addr = rqstp->
>> +                                                               rq_daddr.addr;
>> +                        break;
>> +               case AF_INET6:
>> +                       ((struct sockaddr_in6 *)&s_sa)->sin6_family = AF_INET6;
>> +                       ((struct sockaddr_in6 *)&s_sa)->sin6_addr = rqstp->
>> +                                                               rq_daddr.addr6;
>> +                       break;
>> +       }
>> +       rpc_copy_addr((struct sockaddr *)&conn->cb_saddr, &s_sa);
> 
> Chuck, is there any reason we use this special svc_addr_u union and not
> a struct sockaddr_storage?  This seems more verbose than necessary....

I don't recall creating svc_addr_u, but I'll take a stab at a guess.

It looks like someone thought that we should retain the idea of storing just the address part of the socket address, and not the other stuff (like the family and port, since this code doesn't appear to need that additional information).  It greatly reduces the size of the field.  A full sockaddr_storage is more than 128 bytes, since it has to be able to store an AF_UNIX pathname.

Doing this, there is a lot less data to keep around, but an IPv6 socket address has other items outside of in6_addr that can be used to form a full address.  We decided at some point we could copy this information from the other address storage field in the rqstp.

But the result of this space savings means we must construct a full socket address when needed, using logic such as the above.

> 
> --b.
> 
>>        return;
>> out_err:
>>        conn->cb_addr.ss_family = AF_UNSPEC;
>> @@ -1876,7 +1891,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>         * for consistent minorversion use throughout:
>>         */
>>        new->cl_minorversion = 0;
>> -       gen_callback(new, setclid, rpc_get_scope_id(sa));
>> +       gen_callback(new, setclid, rpc_get_scope_id(sa), rqstp);
>>        add_to_unconfirmed(new, strhashval);
>>        setclid->se_clientid.cl_boot = new->cl_clientid.cl_boot;
>>        setclid->se_clientid.cl_id = new->cl_clientid.cl_id;
>> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
>> index 39adc27..0cee03d 100644
>> --- a/fs/nfsd/state.h
>> +++ b/fs/nfsd/state.h
>> @@ -95,6 +95,7 @@ struct nfs4_delegation {
>> struct nfs4_cb_conn {
>>        /* SETCLIENTID info */
>>        struct sockaddr_storage cb_addr;
>> +       struct sockaddr_storage cb_saddr;
>>        size_t                  cb_addrlen;
>>        u32                     cb_prog; /* used only in 4.0 case;
>>                                            per-session otherwise */
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




