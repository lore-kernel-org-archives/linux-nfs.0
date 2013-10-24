Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1520 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755832Ab3JXUGR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Oct 2013 16:06:17 -0400
Message-ID: <52697DE6.10806@RedHat.com>
Date: Thu, 24 Oct 2013 16:07:02 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH nfs-utils] mountd: fix bug affecting exports of dirs with
 64bit inode number.
References: <20131022100329.20f37a19@notabene.brown>
In-Reply-To: <20131022100329.20f37a19@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 21/10/13 19:03, NeilBrown wrote:
> 
> 
> parse_fsid() is currently truncating all inode numbers to
> 32bits, and assumes that 'int' is 32 bits (which it probably is,
> but we shouldn't assume).
> 
> So make the 'inode' field in 'struct parsed_fsid' a 64 bit field.
> and only memcpy into variables or fields that have been declared
> to a specific bit size.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed... 

steved.

> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 517aa62..e04b86e 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -388,10 +388,10 @@ struct parsed_fsid {
>  	int fsidtype;
>  	/* We could use a union for this, but it would be more
>  	 * complicated; why bother? */
> -	unsigned int inode;
> +	uint64_t inode;
>  	unsigned int minor;
>  	unsigned int major;
> -	unsigned int fsidnum;
> +	uint32_t fsidnum;
>  	size_t uuidlen;
>  	char *fhuuid;
>  };
> @@ -399,8 +399,8 @@ struct parsed_fsid {
>  static int parse_fsid(int fsidtype, int fsidlen, char *fsid,
>  		struct parsed_fsid *parsed)
>  {
> -	unsigned int dev;
> -	unsigned long long inode64;
> +	uint32_t dev;
> +	uint32_t inode32;
>  
>  	memset(parsed, 0, sizeof(*parsed));
>  	parsed->fsidtype = fsidtype;
> @@ -409,7 +409,8 @@ static int parse_fsid(int fsidtype, int fsidlen, char *fsid,
>  		if (fsidlen != 8)
>  			return -1;
>  		memcpy(&dev, fsid, 4);
> -		memcpy(&parsed->inode, fsid+4, 4);
> +		memcpy(&inode32, fsid+4, 4);
> +		parsed->inode = inode32;
>  		parsed->major = ntohl(dev)>>16;
>  		parsed->minor = ntohl(dev) & 0xFFFF;
>  		break;
> @@ -420,7 +421,7 @@ static int parse_fsid(int fsidtype, int fsidlen, char *fsid,
>  		memcpy(&parsed->fsidnum, fsid, 4);
>  		break;
>  
> -	case FSID_MAJOR_MINOR: /* 12 bytes: 4 major, 4 minor, 4 inode 
> +	case FSID_MAJOR_MINOR: /* 12 bytes: 4 major, 4 minor, 4 inode
>  		 * This format is never actually used but was
>  		 * an historical accident
>  		 */
> @@ -430,7 +431,8 @@ static int parse_fsid(int fsidtype, int fsidlen, char *fsid,
>  		parsed->major = ntohl(dev);
>  		memcpy(&dev, fsid+4, 4);
>  		parsed->minor = ntohl(dev);
> -		memcpy(&parsed->inode, fsid+8, 4);
> +		memcpy(&inode32, fsid+8, 4);
> +		parsed->inode = inode32;
>  		break;
>  
>  	case FSID_ENCODE_DEV: /* 8 bytes: 4 byte packed device number, 4 inode */
> @@ -440,7 +442,8 @@ static int parse_fsid(int fsidtype, int fsidlen, char *fsid,
>  		if (fsidlen != 8)
>  			return -1;
>  		memcpy(&dev, fsid, 4);
> -		memcpy(&parsed->inode, fsid+4, 4);
> +		memcpy(&inode32, fsid+4, 4);
> +		parsed->inode = inode32;
>  		parsed->major = (dev & 0xfff00) >> 8;
>  		parsed->minor = (dev & 0xff) | ((dev >> 12) & 0xfff00);
>  		break;
> @@ -448,7 +451,8 @@ static int parse_fsid(int fsidtype, int fsidlen, char *fsid,
>  	case FSID_UUID4_INUM: /* 4 byte inode number and 4 byte uuid */
>  		if (fsidlen != 8)
>  			return -1;
> -		memcpy(&parsed->inode, fsid, 4);
> +		memcpy(&inode32, fsid, 4);
> +		parsed->inode = inode32;
>  		parsed->uuidlen = 4;
>  		parsed->fhuuid = fsid+4;
>  		break;
> @@ -467,8 +471,7 @@ static int parse_fsid(int fsidtype, int fsidlen, char *fsid,
>  	case FSID_UUID16_INUM: /* 8 byte inode number and 16 byte uuid */
>  		if (fsidlen != 24)
>  			return -1;
> -		memcpy(&inode64, fsid, 8);
> -		parsed->inode = inode64;
> +		memcpy(&parsed->inode, fsid, 8);
>  		parsed->uuidlen = 16;
>  		parsed->fhuuid = fsid+8;
>  		break;
> 
