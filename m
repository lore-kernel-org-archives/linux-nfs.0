From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Invalid mount option values should fail even with "sloppy"
Date: Sat, 13 Jun 2009 17:55:33 -0400
Message-ID: <984DFA28-DDFB-46F5-BD2B-16DCB80C7137@oracle.com>
References: <20090612221659.25437.19858.stgit@isabey.1015granger.net> <1244912830.6803.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:43139 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965AbZFMVzk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Jun 2009 17:55:40 -0400
In-Reply-To: <1244912830.6803.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 13, 2009, at 1:07 PM, Trond Myklebust wrote:

> On Fri, 2009-06-12 at 18:19 -0400, Chuck Lever wrote:
>> Ian Kent reports:
>>
>> "I've noticed a couple of other regressions with the options vers
>> and proto option of mount.nfs(8).
>>
>> The commands:
>>
>> mount -t nfs -o vers=<invalid version> <server>:/<path> /<mountpoint>
>> mount -t nfs -o proto=<invalid proto> <server>:/<path> /<mountpoint>
>>
>> both immediately fail.
>>
>> But if the "-s" option is also used they both succeed with the
>> mount falling back to defaults (by the look of it).
>>
>> In the past these failed even when the sloppy option was given, as
>> I think they should. I believe the sloppy option is meant to allow
>> the mount command to still function for mount options (for example
>> in shared autofs maps) that exist on other Unix implementations but
>> aren't present in the Linux mount.nfs(8). So, an invalid value
>> specified for a known mount option is different to an unknown mount
>> option and should fail appropriately."
>>
>> See RH bugzilla 486266.
>>
>> Address the problem by separating parsing errors into two categories.
>> Invalid options will fail only if sloppy isn't set, but invalid
>> values will always fail.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> Trond-
>>
>> Request For Comments only.  Ian hasn't tested this yet, but I was  
>> hoping
>> it could find its way into 2.6.31 at some point, if it looks  
>> correct to
>> you.
>>
>> fs/nfs/super.c |   57 ++++++++++++++++++++++++++++++ 
>> +-------------------------
>> 1 files changed, 32 insertions(+), 25 deletions(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 66ffd5d..e88c527 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -957,7 +957,7 @@ static int nfs_parse_mount_options(char *raw,
>> 				   struct nfs_parsed_mount_data *mnt)
>> {
>> 	char *p, *string, *secdata;
>> -	int rc, sloppy = 0, errors = 0;
>> +	int rc, sloppy = 0, invalid_options = 0, invalid_values = 0;
>
> Why add a counter? Why not just add a variable to hold the return  
> value
>
>          int ret = 0;
>
> ...and have the invalid values set ret=1?

That would probably work for invalid values, which should always cause  
a failure.  I guess I preferred treating the two as similarly as  
possible until the logic at the end.  That seemed a little more clear  
to me.

We still need to sort invalid options if sloppy is set.  Renaming the  
variable @errors seems like a good way to document what exactly we're  
counting.

I'll respin.

>> 	if (!raw) {
>> 		dfprintk(MOUNT, "NFS: mount options string was NULL.\n");
>> @@ -1092,77 +1092,77 @@ static int nfs_parse_mount_options(char *raw,
>> 		case Opt_port:
>> 			if (match_int(args, &option) ||
>> 			    option < 0 || option > USHORT_MAX) {
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("port");
>> 			} else
>> 				mnt->nfs_server.port = option;
>> 			break;
>> 		case Opt_rsize:
>> 			if (match_int(args, &option) || option < 0) {
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("rsize");
>> 			} else
>> 				mnt->rsize = option;
>> 			break;
>> 		case Opt_wsize:
>> 			if (match_int(args, &option) || option < 0) {
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("wsize");
>> 			} else
>> 				mnt->wsize = option;
>> 			break;
>> 		case Opt_bsize:
>> 			if (match_int(args, &option) || option < 0) {
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("bsize");
>> 			} else
>> 				mnt->bsize = option;
>> 			break;
>> 		case Opt_timeo:
>> 			if (match_int(args, &option) || option <= 0) {
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("timeo");
>> 			} else
>> 				mnt->timeo = option;
>> 			break;
>> 		case Opt_retrans:
>> 			if (match_int(args, &option) || option <= 0) {
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("retrans");
>> 			} else
>> 				mnt->retrans = option;
>> 			break;
>> 		case Opt_acregmin:
>> 			if (match_int(args, &option) || option < 0) {
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("acregmin");
>> 			} else
>> 				mnt->acregmin = option;
>> 			break;
>> 		case Opt_acregmax:
>> 			if (match_int(args, &option) || option < 0) {
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("acregmax");
>> 			} else
>> 				mnt->acregmax = option;
>> 			break;
>> 		case Opt_acdirmin:
>> 			if (match_int(args, &option) || option < 0) {
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("acdirmin");
>> 			} else
>> 				mnt->acdirmin = option;
>> 			break;
>> 		case Opt_acdirmax:
>> 			if (match_int(args, &option) || option < 0) {
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("acdirmax");
>> 			} else
>> 				mnt->acdirmax = option;
>> 			break;
>> 		case Opt_actimeo:
>> 			if (match_int(args, &option) || option < 0) {
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("actimeo");
>> 			} else
>> 				mnt->acregmin = mnt->acregmax =
>> @@ -1170,7 +1170,7 @@ static int nfs_parse_mount_options(char *raw,
>> 			break;
>> 		case Opt_namelen:
>> 			if (match_int(args, &option) || option < 0) {
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("namlen");
>> 			} else
>> 				mnt->namlen = option;
>> @@ -1178,7 +1178,7 @@ static int nfs_parse_mount_options(char *raw,
>> 		case Opt_mountport:
>> 			if (match_int(args, &option) ||
>> 			    option < 0 || option > USHORT_MAX) {
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("mountport");
>> 			} else
>> 				mnt->mount_server.port = option;
>> @@ -1187,14 +1187,14 @@ static int nfs_parse_mount_options(char *raw,
>> 			if (match_int(args, &option) ||
>> 			    option < NFS_MNT_VERSION ||
>> 			    option > NFS_MNT3_VERSION) {
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("mountvers");
>> 			} else
>> 				mnt->mount_server.version = option;
>> 			break;
>> 		case Opt_nfsvers:
>> 			if (match_int(args, &option)) {
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("nfsvers");
>> 				break;
>> 			}
>> @@ -1206,7 +1206,7 @@ static int nfs_parse_mount_options(char *raw,
>> 				mnt->flags |= NFS_MOUNT_VER3;
>> 				break;
>> 			default:
>> -				errors++;
>> +				invalid_values++;
>> 				nfs_parse_invalid_value("nfsvers");
>> 			}
>> 			break;
>> @@ -1221,7 +1221,7 @@ static int nfs_parse_mount_options(char *raw,
>> 			rc = nfs_parse_security_flavors(string, mnt);
>> 			kfree(string);
>> 			if (!rc) {
>> -				errors++;
>> +				invalid_values++;
>> 				dfprintk(MOUNT, "NFS:   unrecognized "
>> 						"security flavor\n");
>> 			}
>> @@ -1249,7 +1249,7 @@ static int nfs_parse_mount_options(char *raw,
>> 				xprt_load_transport(string);
>> 				break;
>> 			default:
>> -				errors++;
>> +				invalid_values++;
>> 				dfprintk(MOUNT, "NFS:   unrecognized "
>> 						"transport protocol\n");
>> 			}
>> @@ -1272,7 +1272,7 @@ static int nfs_parse_mount_options(char *raw,
>> 				break;
>> 			case Opt_xprt_rdma: /* not used for side protocols */
>> 			default:
>> -				errors++;
>> +				invalid_values++;
>> 				dfprintk(MOUNT, "NFS:   unrecognized "
>> 						"transport protocol\n");
>> 			}
>> @@ -1330,7 +1330,7 @@ static int nfs_parse_mount_options(char *raw,
>> 					mnt->flags |= NFS_MOUNT_LOOKUP_CACHE_NONEG| 
>> NFS_MOUNT_LOOKUP_CACHE_NONE;
>> 					break;
>> 				default:
>> -					errors++;
>> +					invalid_values++;
>> 					dfprintk(MOUNT, "NFS:   invalid "
>> 							"lookupcache argument\n");
>> 			};
>> @@ -1350,15 +1350,22 @@ static int nfs_parse_mount_options(char *raw,
>> 			break;
>>
>> 		default:
>> -			errors++;
>> +			invalid_options++;
>> 			dfprintk(MOUNT, "NFS:   unrecognized mount option "
>> 					"'%s'\n", p);
>> 		}
>> 	}
>>
>> -	if (errors > 0) {
>> -		dfprintk(MOUNT, "NFS: parsing encountered %d error%s\n",
>> -				errors, (errors == 1 ? "" : "s"));
>> +	if (invalid_values > 0) {
>> +		dfprintk(MOUNT, "NFS: parsing encountered %d invalid value%s\n",
>> +				invalid_values,
>> +				invalid_values == 1 ? "" : "s");
>> +		return 0;
>> +	}
>> +	if (invalid_options > 0) {
>> +		dfprintk(MOUNT, "NFS: parsing encountered %d invalid option%s\n",
>> +				invalid_options,
>> +				invalid_options == 1 ? "" : "s");
>> 		if (!sloppy)
>> 			return 0;
>> 	}
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



