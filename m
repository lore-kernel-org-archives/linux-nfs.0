From: Chuck Lever <chuck.lever-Onf44Ee+mfbQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Allow nfs/vers=4 option in text-based mount commands
Date: Thu, 7 May 2009 16:47:42 -0400
Message-ID: <7AA4E5E5-19E7-4965-B5AB-58EEA2AA2607@Oracle.com>
References: <1241560004-16787-1-git-send-email-kevin.constantine@disneyanimation.com> <1241560004-16787-2-git-send-email-kevin.constantine@disneyanimation.com> <1241560004-16787-3-git-send-email-kevin.constantine@disneyanimation.com> <6BEE21E5-A57E-46EA-A9A2-AED95715BFDE@oracle.com> <4A033E7C.9060605@disney.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: multipart/mixed; boundary=Apple-Mail-2--718426218
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Steve Dickson <SteveD@redhat.com>
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:58382 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751558AbZEGUsK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2009 16:48:10 -0400
In-Reply-To: <4A033E7C.9060605-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail-2--718426218
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit


On May 7, 2009, at 4:03 PM, Kevin Constantine wrote:

> Chuck Lever wrote:
>> On May 5, 2009, at 5:46 PM, Kevin Constantine wrote:
>>> This allows a user to specify nfsvers=4, or vers=4 on the mount
>>> commandline and have mount.nfs4 called as though fstype=nfs4 were
>>> specified.  This patch handles the nfsmount_string case in
>>> mount.c's try_mount().
>>>
>>> We get the value of the "vers=" or "nfsvers=" from the nfsmount_info
>>> structure, and if the value equals 4, we set the fstype to nfs4, and
>>> remove the nfsvers/vers options from the structure since it  
>>> shouldn't
>>> be there in the first place, and we don't want to pass it along down
>>> the stack.
>>>
>>> po_get_numeric returns the rightmost instance, so we honor the last
>>> value of nfsvers/vers in the event that it is overridden later in  
>>> the
>>> options string.
>>>
>>> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org 
>>> >
>>> ---
>>> utils/mount/stropts.c |    9 +++++++++
>>> 1 files changed, 9 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>> index c369136..72b0d13 100644
>>> --- a/utils/mount/stropts.c
>>> +++ b/utils/mount/stropts.c
>>> @@ -754,6 +754,15 @@ static const char *nfs_background_opttbl[] = {
>>>
>>> static int nfsmount_start(struct nfsmount_info *mi)
>>> {
>>> +    long tmp;
>>> +    po_get_numeric(mi->options, "vers", &tmp);
>>> +    po_get_numeric(mi->options, "nfsvers", &tmp);
>> If someone specifies both a vers= and a nfsvers= on the command  
>> line, this won't handle it.  You need to implement a rightmost  
>> search, as Steve's patch (posted previously on this list) did.
>
> I can't seem to find Steve's patches relating to this issue.  I'm  
> assuming that since there are already patches related to this, it's  
> not worth pursuing these particular patches.

It was on the NFSv4 mailing list.  Sorry about that.


--Apple-Mail-2--718426218
Content-Disposition: attachment;
	filename*0="Re: [PATCH] [RFC] Enable v4 mounts when either \"nfsvers=4\" or \"v";
	filename*1="ers=4\" option are set..eml"
Content-Type: message/rfc822;
	x-mac-hide-extension=yes;
	x-unix-mode=0666;
	name="Re: [PATCH] [RFC] Enable v4 mounts when either \"nfsvers=4\" or \"vers=4\" option are set..eml"
Content-Transfer-Encoding: 7bit

Received: from acsmt356.oracle.com (/141.146.46.1)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 24 Mar 2009 10:02:42 -0700
Return-Path: <nfsv4-bounces@linux-nfs.org>
Received: from rcsinet15.oracle.com by acsmt354.oracle.com
	with ESMTP id 15980064401237914154; Tue, 24 Mar 2009 10:02:34 -0700
Received: from acsinet12.oracle.com (acsinet12.oracle.com [141.146.126.234])
	by rgminet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n2OH2WYv032083
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <chuck.lever@oracle.com>; Tue, 24 Mar 2009 17:02:34 GMT
Received: from linux-nfs.citi.umich.edu (linux-nfs.citi.umich.edu [141.211.133.37])
	by acsinet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n2OH216h015886
	for <chuck.lever@oracle.com>; Tue, 24 Mar 2009 17:02:03 GMT
Received: from linux-nfs.citi.umich.edu (localhost.localdomain [127.0.0.1])
	by linux-nfs.citi.umich.edu (Postfix) with ESMTP id 9689F6801870;
	Tue, 24 Mar 2009 13:02:22 -0400 (EDT)
X-Original-To: nfsv4@linux-nfs.org
Delivered-To: nfsv4@linux-nfs.org
Received: from rgminet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by linux-nfs.citi.umich.edu (Postfix) with ESMTP id 1B1A16800532
	for <nfsv4@linux-nfs.org>; Tue, 24 Mar 2009 13:02:20 -0400 (EDT)
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id
	n2OH3X3G017304
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK);
	Tue, 24 Mar 2009 17:03:34 GMT
Received: from acsmt707.oracle.com (acsmt707.oracle.com [141.146.40.85])
	by rgminet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id
	n2OH2IFe031256; Tue, 24 Mar 2009 17:02:19 GMT
Received: from manet.1015granger.net (/76.241.169.38)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 24 Mar 2009 10:02:11 -0700
Message-Id: <8B1CA12E-5B35-4DA1-B48C-0916D27CD9AB@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <49C7B5C2.4030503-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Subject: Re: [PATCH] [RFC] Enable v4 mounts when either "nfsvers=4" or
	"vers=4" option are set.
Date: Tue, 24 Mar 2009 13:02:09 -0400
References: <49C3C681.3070300-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
	<FC5604DE-AD89-47FC-8A05-93A6B984BBD9@oracle.com>
	<49C3D5E4.102-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
	<51C8E920-31A4-4C8E-813A-9C510D49592C@oracle.com>
	<49C7B5C2.4030503-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
X-Mailer: Apple Mail (2.930.3)
X-Source-IP: linux-nfs.citi.umich.edu [141.211.133.37]
X-CT-RefId: str=0001.0A090207.49C91221.0243,ss=1,fgs=0
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
X-BeenThere: nfsv4@linux-nfs.org
X-Mailman-Version: 2.1.9
Precedence: list
List-Id: Discussion of the linux nfsv4 client and server <nfsv4.linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org

Hi Steve-

Yep, this is the idea.  Comments below.

On Mar 23, 2009, at 12:16 PM, Steve Dickson wrote:
> Chuck Lever wrote:
>> On Mar 20, 2009, at Mar 20, 2009, 1:44 PM, Steve Dickson wrote:
>>> Chuck Lever wrote:
>>>> Hi Steve-
>>>>
>>>> You could limit this to just text-based mounts, then the existing  
>>>> option
>>>> parser would handle most of this for you.
>>>>
>>> I took a look at that approach... Basically have parse_opts() and/or
>>> parse_opt() do the work figuring out what nfsvers or vers is set to.
>>> But the problem with that, I would have to pass down the address of
>>> fs_type pointer so I could overwritten... Adding that extra  
>>> parameter
>>> I didn't think was the best approach... bordering on the hacky  
>>> side...
>>>
>>> So took the approach of lets set file system type once and only  
>>> once...
>>> Unfortunately that approach does call for me to strip out the  
>>> "nfsvers"
>>> or "vers" string from that options string...
>>
>> The text-based path uses a single data structure, nfs_mountinfo,  
>> which
>> carries all the mount data through the whole code path.  In
>> nfsmount_start() you can add a little logic that resets the fs_type  
>> (in
>> the .type field) before proceeding with the rest of the mount.
>>
>> You would also need to expose nfs_nfs_version() in utils/mount/ 
>> network.c
>> (and add support for version 4) so you can handle the case where  
>> someone
>> specifies "vers=" more than once on the command line (or specifies
>> something obnoxious like "v2,nfsvers=4,vers=3", and you can also  
>> detect
>> "v4" here as well.
>>
>> There is code at the top of nfs_construct_new_options() which  
>> provides
>> an example of how to easily strip out the existing vers options.
>>
>> So nfsmount_start() could call nfs_nfs_version to see what version to
>> use if the passed-in fs_type is "nfs", and if it's version 4, just
>> remove all the vers options, and say 'mi.type = "nfs4";'.
>>
>> All that assumes you don't care about providing nfsvers=4 support for
>> legacy non-text-based mounts.
> Here is the patch implementing  your suggestion...
>
> The patches are about the same size... As you mentioned this patch
> does not provide legacy support, which may or may not matter...
>
> Both patches have to remove the version option from the list
> pumped down to the kernel, since the option will cause the
> kernel routines to error out... Its much cleaner to
> remove moved the option 'mount_options' list than stripping
> the option from the string.
>
> So I guess it comes down to do we really care about legacy support??

I don't have a strong opinion, but my preference would be to leave  
enhancements like this to text-based mounts only.

> steved.
>
> Using only the string option parsing routine, allow the file system
> type to be changed to 'nfs4' when the NFS version options are  
> specified.
>
>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> -----------
>
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index bcd0c0f..612c9c2 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -94,6 +94,12 @@ static const char *nfs_version_opttbl[] = {
> 	"nfsvers",
> 	NULL,
> };
> +static const char *nfs_fstype_opttbl[] = {
> +	"v4",
> +	"vers",
> +	"nfsvers",
> +	NULL,
> +};
>
> static const unsigned long nfs_to_mnt[] = {
> 	0,
> @@ -1242,6 +1248,47 @@ static rpcvers_t nfs_nfs_version(struct  
> mount_options *options)
> }
>
> /*
> + * Returns either "nfs" or "nfs4" as the file system type
> + * depending on which (if any) of the nfs version options
> + * are specified.
> + */
> +char *nfs_fs_type(struct mount_options *options)
> +{
> +	char *keyword;
> +	long tmp;
> +	static char *fs_type = "nfs";
> +
> +	switch (po_rightmost(options, nfs_fstype_opttbl)) {

As far as I recall, we recently fixed po_rightmost() to return a C- 
style array offset.  Shouldn't the cases be 0, 1, and 2?

> +	case 2: /* v4 */
> +		keyword = "v4";
> +		break;
> +	case 3:	/* vers */
> +		if (po_get_numeric(options, "vers", &tmp) == PO_FOUND)
> +			if (tmp != 4)
> +				return fs_type;
> +		keyword = "vers";
> +		break;
> +	case 4: /* nfsvers */
> +		if (po_get_numeric(options, "nfsvers", &tmp) == PO_FOUND)
> +			if (tmp != 4)
> +				return fs_type;
> +		keyword = "nfsvers";
> +		break;
> +	default:
> +		return fs_type;
> +	}
> +
> +	/*
> +	 * Need to remove the v4 version option from the
> +	 * list since the kernel will not how to parse it.
> +	 */
> +	po_remove_all(options, keyword);

You always need to remove all of "nfsvers," "vers", "v2", "v3", and  
"v4" if this is a nfs4 mount.  The reason for this is to make sure the  
user hasn't specified something bogus like "nfsvers=2,vers=3,v4".  In  
that case the correct behavior is to do a "nfs4" mount and strip out  
all verison options.  For something like "v4,nfsvers=3,vers=2" the  
correct behavior is to do a "nfs" mount and remove any v4-related  
version options (which the kernel won't like).  The rule is "rightmost  
wins".

So you need two exits from this function:

  * for "nfs" mounts, return "nfs" and make sure any of "v4"  
"nfsvers=4" or "vers=4" are removed, and

  * for "nfs4" mounts, return "nfs4" and strip all version options  
from the mount string.

> +	fs_type = "nfs4";
> +
> +	return fs_type;

I'm pretty sure you can get the same effect (returning a statically  
allocated character string) with:

	return "nfs4";

> +}
> +
> +/*
>  * Returns the NFS transport protocol specified by the given mount  
> options
>  *
>  * Returns the IPPROTO_ value specified by the given mount options, or
> diff --git a/utils/mount/network.h b/utils/mount/network.h
> index 0dd90f8..203e728 100644
> --- a/utils/mount/network.h
> +++ b/utils/mount/network.h
> @@ -64,6 +64,7 @@ void nfs_options2pmap(struct mount_options *,
> int start_statd(void);
>
> unsigned long nfsvers_to_mnt(const unsigned long);
> +char *nfs_fs_type(struct mount_options *);

If you're not going to use nfs_nfs_version() at all, then this  
function would be better off living in utils/mount/stropts.c.   
network.c is just for the network-related functions (like creating a  
socket, handling DNS lookups, or doing getport calls), and they are  
generally shared between legacy and text-based support.  This is  
clearly going to be a text-based-only kind of thing.

> int nfs_call_umount(clnt_addr_t *, dirpath *);
> int nfs_advise_umount(const struct sockaddr *, const socklen_t,
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index c369136..7a4f533 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -754,6 +754,9 @@ static const char *nfs_background_opttbl[] = {
>
> static int nfsmount_start(struct nfsmount_info *mi)
> {
> +
> +	mi->type = nfs_fs_type(mi->options);
> +
> 	if (!nfs_validate_options(mi))
> 		return EX_FAIL;

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

--Apple-Mail-2--718426218
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7bit




--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
--Apple-Mail-2--718426218--
