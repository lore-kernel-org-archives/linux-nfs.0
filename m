From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [Patch 1/10] NFS Mount Configuration File (Vers 3)
Date: Fri, 07 Aug 2009 11:06:04 +0300
Message-ID: <4A7BE06C.4080607@panasas.com>
References: <4A7B2324.9090406@RedHat.com> <4A7B238A.5010608@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A7B238A.5010608@RedHat.com>
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

On Aug. 06, 2009, 21:40 +0300, Steve Dickson <SteveD@redhat.com> wrote:
<snip>


> +/*
> + * Parse the line LINE of SZ bytes.  Skip Comments, recognize section
> + * headers and feed tag-value pairs into our configuration database.
> + */
> +static void
> +conf_parse_line(int trans, char *line, size_t sz)
> +{
> +	char *val;
> +	size_t i;
> +	int j;
> +	static char *section = 0;
> +	static int ln = 0;
> +
> +	/* Lines starting with '#' or ';' are comments.  */
> +	ln++;
> +	if (*line == '#' || *line == ';')
> +		return;
> +
> +	/* '[section]' parsing...  */
> +	if (*line == '[') {
> +		for (i = 1; i < sz; i++)
> +			if (line[i] == ']')
> +				break;
> +		if (section)
> +			free (section);
> +		if (i == sz) {
> +			xlog_warn("conf_parse_line: %d:"
> + 				"non-matched ']', ignoring until next section", ln);
> +			section = 0;
> +			return;
> +		}
> +		section = malloc(i);
> +		if (!section) {
> +			xlog_warn("conf_parse_line: %d: malloc (%lu) failed", ln,
> +						(unsigned long)i);
> +			return;
> +		}
> +		strlcpy(section, line + 1, i);
> +		return;
> +	}
> +
> +	/* Deal with assignments.  */
> +	for (i = 0; i < sz; i++) {
> +		if (line[i] == '=') {
> +			/* If no section, we are ignoring the lines.  */
> +			if (!section) {
> +				xlog_warn("conf_parse_line: %d: ignoring line due to no section", 
> +					ln);
> +				return;
> +			}
> +			line[strcspn (line, " \t=")] = '\0';
> +			val = line + i + 1 + strspn (line + i + 1, " \t");
> +			/* Skip trailing whitespace, if any */
> +			for (j = sz - (val - line) - 1; j > 0 && isspace(val[j]); j--)
> +				val[j] = '\0';

Should we break on the first non space?
This will allow spaces in the value...
Should we skip trailing comments as well (';' in particular)? I.e.:

			/* Skip trailing comments, if any */
			for (j = 0; j < sz - (val - line); j++) {
				if (val[j] == '#' || val[j] == ';') {
					val[j] = '\0';
					break;
				}
			}
			/* Skip trailing whitespace, if any */
			for (j--; j > 0; j--) {
				if (isspace(val[j]))
					val[j] = '\0';
				else
					break;
			}

Benny

> +			/* XXX Perhaps should we not ignore errors?  */
> +			conf_set(trans, section, line, val, 0, 0);
> +			return;
> +		}
> +	}
> +	/* Other non-empty lines are weird.  */
> +	i = strspn(line, " \t");
> +	if (line[i])
> +		xlog_warn("conf_parse_line: %d: syntax error", ln);
> +
> +	return;
> +}
> +
