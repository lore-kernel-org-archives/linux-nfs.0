Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54202 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752427Ab3ALCK1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jan 2013 21:10:27 -0500
Date: Fri, 11 Jan 2013 21:10:20 -0500
To: fanchaoting <fanchaoting@cn.fujitsu.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        wireshark-dev@wireshark.org
Subject: Re: [PATCH] wireshark: can't decode callback if didn't caught
 CREATE_SESSION and SETCLIENTID packets before
Message-ID: <20130112021020.GA32128@fieldses.org>
References: <50EFDEEA.4040201@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50EFDEEA.4040201@cn.fujitsu.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 11, 2013 at 05:44:10PM +0800, fanchaoting wrote:
> now i found that nfs kernel use 0x40000000 as callback program number.
> the CREATE_SESSION and SETCLIENTID use 0x40000000 as callback program number,
> and they didn't change it.
>
> but i found that i use wireshark to decode nfsv4 callback procedures, it didn't
> decode them if the wireshark or tcpdump didn't caught CREATE_SESSION and SETCLIENTID
> packets before.

No, this change is incorrect.

It may be true that the current linux client always uses that program
number, but the protocol does allow the client to choose any program
number it wants, and I would not be surprised if other clients use
something different.

There might be some other heuristic we could use to find the callbacks
in the case we didn't capture CREATE_SESSION or SETCLIENTID--maybe it
would be OK to just guess that 4 is the right number in that case--but
we must not ignore the provided cb program in the case where we do see
it.

--b.

> 
> Signed-off-by: Fan Chaoting <fanchaoting@cn.fujitsu.com>
> 
> ---
>  epan/dissectors/packet-nfs.c |   10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/epan/dissectors/packet-nfs.c b/epan/dissectors/packet-nfs.c
> index 63d1019..7b5ec88 100644
> --- a/epan/dissectors/packet-nfs.c
> +++ b/epan/dissectors/packet-nfs.c
> @@ -7979,10 +7979,7 @@ dissect_nfs_cb_client4(tvbuff_t *tvb, int offset, proto_tree *tree)
>  {
>  	proto_tree *cb_location = NULL;
>  	proto_item *fitem = NULL;
> -	int cbprog;
>  
> -	cbprog = tvb_get_ntohl(tvb, offset);
> -	reg_callback(cbprog);
>  	offset = dissect_rpc_uint32(tvb, tree, hf_nfs_cb_program, offset);
>  	fitem = proto_tree_add_text(tree, tvb, offset, 0, "cb_location");
>  
> @@ -8991,7 +8988,6 @@ dissect_nfs_argop4(tvbuff_t *tvb, int offset, packet_info *pinfo,
>  	proto_tree *ftree = NULL;
>  	proto_tree *newftree = NULL;
>  	guint32 string_length;
> -	int cbprog;
>  	const char *name = NULL, *source_name = NULL, *dest_name=NULL;
>  	const char *opname=NULL;
>  	guint32 last_fh_hash=0;
> @@ -9012,6 +9008,10 @@ dissect_nfs_argop4(tvbuff_t *tvb, int offset, packet_info *pinfo,
>  		"Operations (count: %u)", ops);
>  	offset += 4;
>  
> +	 /*Now the nfs use '0x40000000' as callback's program number.*/
> +#define CB_PROG 0x40000000
> +	reg_callback(CB_PROG);
> +
>  #define MAX_NFSV4_OPS 128
>  
>  	if (ops > MAX_NFSV4_OPS) {
> @@ -9469,8 +9469,6 @@ dissect_nfs_argop4(tvbuff_t *tvb, int offset, packet_info *pinfo,
>  			offset = dissect_nfs_create_session_flags(tvb, offset, newftree, hf_nfs_create_session_flags_csa);
>  			offset = dissect_rpc_chanattrs4(tvb, offset, newftree, "csa_fore_chan_attrs");
>  			offset = dissect_rpc_chanattrs4(tvb, offset, newftree, "csa_back_chan_attrs");
> -			cbprog = tvb_get_ntohl(tvb, offset);
> -			reg_callback(cbprog);
>  			offset = dissect_rpc_uint32(tvb, newftree, hf_nfs_cb_program, offset);
>  			offset = dissect_rpc_secparms4(tvb, offset, newftree);
>  			break;
> -- 
> 1.7.10.1


