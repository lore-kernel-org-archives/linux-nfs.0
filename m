Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5023 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764Ab2DPKvm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Apr 2012 06:51:42 -0400
Message-ID: <4F8BF9B5.6000604@RedHat.com>
Date: Mon, 16 Apr 2012 06:51:33 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: Michael Weiser <M.Weiser@science-computing.de>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4 post-1.2.2 nfs-utils client fails to mount from pre-1.2.3
 nfs-utils server
References: <5dad9f48aa83cc6af5f51fb3a5c076e0.squirrel@webmail.science-computing.de> <CAKnQG+f3cG0q8Zoan=cc85qD5MUqqiwgnxFeq1ygTmGip+Kp5w@mail.gmail.com> <20120313144214.GB16920@science-computing.de> <CAKnQG+ezssmHZCAogTuWC7+ubAn8YjUtOF1MJ0Fw4rr7Z_srhw@mail.gmail.com> <20120314134829.GA943@science-computing.de> <20120319130043.GG9020@science-computing.de> <4F686996.5050108@RedHat.com> <20120320174418.GL24828@science-computing.de> <20120329140226.GB1362@science-computing.de> <4F86EA08.5000308@RedHat.com> <20120412154928.GG2351@science-computing.de> <4F86FC8B.7050606@RedHat.com>
In-Reply-To: <4F86FC8B.7050606@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/12/2012 12:02 PM, Steve Dickson wrote:
> 
> 
> On 04/12/2012 11:49 AM, Michael Weiser wrote:
>> Hi Steve,
>>
>> On Thu, Apr 12, 2012 at 10:43:20AM -0400, Steve Dickson wrote:
>>
>>>> How do I go about getting this committed?
>>> My bad... I'm looking into this now....
>>
>> Thanks for getting back to me.
>>
>>>>> I just noticed that while the code bits are optional based on
>>>>> HAVE_SET_ALLOWABLE_ENCTYPES, the man page part isn't. I've got no idea,
>>>>> how to go about that.
>>> I'm think we should remove all those defines and have the code enabled
>>> by default. The main reason is defines like that just clutter up the 
>>> code, plus there would be a needed for another configuration flag
>>> which I think is a bit over kill... 
>>
>> Here it is. The whole HAVE_SET_ALLOWABLE_ENCTYPES logic is still in place
>> but my code now ignores it. So with a GSSAPI implementation that doesn't
>> support it, the -l switch will be accepted by gssd but silently do
>> nothing.
> Well after further review.... it appears remove moving those defines would
> have a negative impact on backwards compatibility with older Kerberos 
> libraries. 
> 
> So what I'm thinking of doing is error out if an admin tries to use the 
> -l flag with incompatible  Kerberos libraries. I also made a note in
> the man page. So how about something like this:
> 
> 
> Author: Michael Weiser <weiser@science-computing.de>
> Date:   Thu Apr 12 11:50:03 2012 -0400
> 
>     Add -l option to gssd to force legacy behaviour
>     
>     Implement a new option -l to force gssd to ignore its kernel's crypto
>     capabilities and use just the Single DES legacy encryption types to be
>     compatible with old servers. This is only relevant if those servers have
>     strong keys in their keytab.
>     
>     Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.
> 
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index d53795e..7825255 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -85,7 +85,7 @@ sig_hup(int signal)
>  static void
>  usage(char *progname)
>  {
> -	fprintf(stderr, "usage: %s [-f] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm]\n",
> +	fprintf(stderr, "usage: %s [-f] [-l] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm]\n",
>  		progname);
>  	exit(1);
>  }
> @@ -102,7 +102,7 @@ main(int argc, char *argv[])
>  	char *progname;
>  
>  	memset(ccachesearch, 0, sizeof(ccachesearch));
> -	while ((opt = getopt(argc, argv, "fvrmnMp:k:d:t:R:")) != -1) {
> +	while ((opt = getopt(argc, argv, "fvrlmnMp:k:d:t:R")) != -1) {
>  		switch (opt) {
>  			case 'f':
>  				fg = 1;
> @@ -143,6 +143,13 @@ main(int argc, char *argv[])
>  			case 'R':
>  				preferred_realm = strdup(optarg);
>  				break;
> +			case 'l':
> +#ifdef HAVE_SET_ALLOWABLE_ENCTYPES
> +				limit_to_legacy_enctypes = 1;
> +#else 
> +				errx(1, "Setting encryption type not support by Kerberos libraries.");
> +#endif
> +				break;
>  			default:
>  				usage(argv[0]);
>  				break;
> diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
> index 073379d..d8138fa 100644
> --- a/utils/gssd/gssd.man
> +++ b/utils/gssd/gssd.man
> @@ -6,7 +6,7 @@
>  .SH NAME
>  rpc.gssd \- rpcsec_gss daemon
>  .SH SYNOPSIS
> -.B "rpc.gssd [-f] [-n] [-k keytab] [-p pipefsdir] [-v] [-r] [-d ccachedir]"
> +.B "rpc.gssd [-f] [-n] [-k keytab] [-l] [-p pipefsdir] [-v] [-r] [-d ccachedir]"
>  .SH DESCRIPTION
>  The rpcsec_gss protocol gives a means of using the gss-api generic security
>  api to provide security for protocols using rpc (in particular, nfs).  Before
> @@ -70,6 +70,30 @@ for "machine credentials" is now:
>  If this search order does not use the correct key then provide a
>  keytab file that contains only correct keys.
>  .TP
> +.B -l
> +Tells
> +.B rpc.gssd
> +to limit session keys to Single DES even if the kernel supports stronger
> +encryption types. Service ticket encryption is still governed by what
> +the KDC believes the target server supports. This way the client can
> +access a server that has strong keys in its keytab for ticket decryption
> +but whose kernel only supports Single DES.
> +.IP
> +The alternative is to put only Single DES keys in the server's keytab
> +and limit encryption types for its principal to Single DES on the KDC
> +which will cause service tickets for this server to be encrypted using
> +only Single DES and (as a side-effect) contain only Single DES session
> +keys.
> +.IP
> +This legacy behaviour is only required for older servers
> +(pre nfs-utils-1.2.4). If the server has a recent kernel, Kerberos
> +implementation and nfs-utils it will work just fine with stronger
> +encryption.
> +.IP
> +.B Note:
> +This option is only available with Kerberos libraries that 
> +support setable encryption types.
> +.TP
>  .B -p path
>  Tells
>  .B rpc.gssd
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 4b13fa1..887d118 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -129,6 +129,10 @@
>  /* Global list of principals/cache file names for machine credentials */
>  struct gssd_k5_kt_princ *gssd_k5_kt_princ_list = NULL;
>  
> +#ifdef HAVE_SET_ALLOWABLE_ENCTYPES
> +int limit_to_legacy_enctypes = 0;
> +#endif
> +
>  /*==========================*/
>  /*===  Internal routines ===*/
>  /*==========================*/
> @@ -1342,7 +1346,7 @@ limit_krb5_enctypes(struct rpc_gss_sec *sec)
>  	 * If we failed for any reason to produce global
>  	 * list of supported enctypes, use local default here.
>  	 */
> -	if (krb5_enctypes == NULL)
> +	if (krb5_enctypes == NULL || limit_to_legacy_enctypes)
>  		maj_stat = gss_set_allowable_enctypes(&min_stat, credh,
>  					&krb5oid, num_enctypes, enctypes);
>  	else
> diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
> index b42b91e..cd6e107 100644
> --- a/utils/gssd/krb5_util.h
> +++ b/utils/gssd/krb5_util.h
> @@ -36,6 +36,7 @@ char *gssd_k5_err_msg(krb5_context context, krb5_error_code code);
>  void gssd_k5_get_default_realm(char **def_realm);
>  
>  #ifdef HAVE_SET_ALLOWABLE_ENCTYPES
> +extern int limit_to_legacy_enctypes;
>  int limit_krb5_enctypes(struct rpc_gss_sec *sec);
>  #endif
>  
> 
> If this seems reasonable, would you mind giving it a test run to 
> ensure I have not broken anything? tia..
> 
> steved.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
