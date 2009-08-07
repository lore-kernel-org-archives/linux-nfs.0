From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [Patch 2/10] NFS Mount Configuration File (Vers 3)
Date: Fri, 07 Aug 2009 13:11:14 -0400
Message-ID: <4A7C6032.4060301@RedHat.com>
References: <4A7B2324.9090406@RedHat.com> <4A7B23D2.6080900@RedHat.com>
	<4A7BE0B2.9010008@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A7BE0B2.9010008@panasas.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/07/2009 04:07 AM, Benny Halevy wrote:
> On Aug. 06, 2009, 21:41 +0300, Steve Dickson <SteveD@redhat.com> wrote:
>> commit f6f4d0b872c01eaffbcb4c3919f13237aa8678e1
>> Author: Steve Dickson <steved@redhat.com>
>> Date:   Mon Mar 9 13:55:25 2009 -0400
>>
>>     Taught conf_parse_line() to ignore spaces in the
>>      '[section]' parsing and before the assignment statements
>>     
>>     Signed-off-by: Steve Dickson <steved@redhat.com>
>>
>> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
>> index c5f9fa7..5f491eb 100644
>> --- a/support/nfs/conffile.c
>> +++ b/support/nfs/conffile.c
>> @@ -50,11 +50,6 @@
>>  #include "xlog.h"
>>  
>>  static void conf_load_defaults (int);
>> -#if 0
>> -static int conf_find_trans_xf (int, char *);
>> -#endif
>> -
>> -size_t  strlcpy(char *, const char *, size_t);
>>  
>>  struct conf_trans {
>>  	TAILQ_ENTRY (conf_trans) link;
>> @@ -219,26 +214,48 @@ conf_parse_line(int trans, char *line, size_t sz)
>>  	if (*line == '#' || *line == ';')
>>  		return;
>>  
>> +	/* Ignore blank lines */
>> +	if (*line == '\0')
>> +		return;
>> +
>> +	/* Strip off any leading blanks */
>> +	while (isblank(*line)) 
>> +		line++;
>> +
> 
> Why not do this before looking for '#' or ';'?
Point, if we supported in-line comments or am I missing 
something? 

steved.
