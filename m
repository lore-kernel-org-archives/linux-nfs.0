Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:17703 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750879Ab3ANFLD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jan 2013 00:11:03 -0500
Message-ID: <50F3937B.6000403@cn.fujitsu.com>
Date: Mon, 14 Jan 2013 13:11:23 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] wireshark: can't decode callback if didn't caught CREATE_SESSION
 and SETCLIENTID packets before
References: <50EFDEEA.4040201@cn.fujitsu.com> <20130112021020.GA32128@fieldses.org>
In-Reply-To: <20130112021020.GA32128@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields 写道:
> On Fri, Jan 11, 2013 at 05:44:10PM +0800, fanchaoting wrote:
>> now i found that nfs kernel use 0x40000000 as callback program number.
>> the CREATE_SESSION and SETCLIENTID use 0x40000000 as callback program number,
>> and they didn't change it.
>>
>> but i found that i use wireshark to decode nfsv4 callback procedures, it didn't
>> decode them if the wireshark or tcpdump didn't caught CREATE_SESSION and SETCLIENTID
>> packets before.
> 
> No, this change is incorrect.
> 
> It may be true that the current linux client always uses that program
> number, but the protocol does allow the client to choose any program
> number it wants, and I would not be surprised if other clients use
> something different.
> 
> There might be some other heuristic we could use to find the callbacks
> in the case we didn't capture CREATE_SESSION or SETCLIENTID--maybe it
> would be OK to just guess that 4 is the right number in that case--but
> we must not ignore the provided cb program in the case where we do see
> it.
> 

thanks , but i think maybe it have some other ways to slove this problem.

> --b.
> 
>> Signed-off-by: Fan Chaoting <fanchaoting@cn.fujitsu.com>
>>
>> ---
>>  epan/dissectors/packet-nfs.c |   10 ++++------
>>  1 file changed, 4 insertions(+), 6 deletions(-)
>>
>> diff --git a/epan/dissectors/packet-nfs.c b/epan/dissectors/packet-nfs.c
>> index 63d1019..7b5ec88 100644
>> --- a/epan/dissectors/packet-nfs.c
>> +++ b/epan/dissectors/packet-nfs.c
>> @@ -7979,10 +7979,7 @@ dissect_nfs_cb_client4(tvbuff_t *tvb, int offset, proto_tree *tree)
>>  {
>>  	proto_tree *cb_location = NULL;
>>  	proto_item *fitem = NULL;
>> -	int cbprog;
>>  
>> -	cbprog = tvb_get_ntohl(tvb, offset);
>> -	reg_callback(cbprog);
>>  	offset = dissect_rpc_uint32(tvb, tree, hf_nfs_cb_program, offset);
>>  	fitem = proto_tree_add_text(tree, tvb, offset, 0, "cb_location");
>>  
>> @@ -8991,7 +8988,6 @@ dissect_nfs_argop4(tvbuff_t *tvb, int offset, packet_info *pinfo,
>>  	proto_tree *ftree = NULL;
>>  	proto_tree *newftree = NULL;
>>  	guint32 string_length;
>> -	int cbprog;
>>  	const char *name = NULL, *source_name = NULL, *dest_name=NULL;
>>  	const char *opname=NULL;
>>  	guint32 last_fh_hash=0;
>> @@ -9012,6 +9008,10 @@ dissect_nfs_argop4(tvbuff_t *tvb, int offset, packet_info *pinfo,
>>  		"Operations (count: %u)", ops);
>>  	offset += 4;
>>  
>> +	 /*Now the nfs use '0x40000000' as callback's program number.*/
>> +#define CB_PROG 0x40000000
>> +	reg_callback(CB_PROG);
>> +
>>  #define MAX_NFSV4_OPS 128
>>  
>>  	if (ops > MAX_NFSV4_OPS) {
>> @@ -9469,8 +9469,6 @@ dissect_nfs_argop4(tvbuff_t *tvb, int offset, packet_info *pinfo,
>>  			offset = dissect_nfs_create_session_flags(tvb, offset, newftree, hf_nfs_create_session_flags_csa);
>>  			offset = dissect_rpc_chanattrs4(tvb, offset, newftree, "csa_fore_chan_attrs");
>>  			offset = dissect_rpc_chanattrs4(tvb, offset, newftree, "csa_back_chan_attrs");
>> -			cbprog = tvb_get_ntohl(tvb, offset);
>> -			reg_callback(cbprog);
>>  			offset = dissect_rpc_uint32(tvb, newftree, hf_nfs_cb_program, offset);
>>  			offset = dissect_rpc_secparms4(tvb, offset, newftree);
>>  			break;
>> -- 
>> 1.7.10.1
> 
> 
> 
> 



